// Full allometric weight model (site-year resolution).
// log(weight) ~ student_t(bNu, mu, sWeight) where
//   mu = bWeight + bYear[year] + bSite[site]
//      + log(bFloor + (1 - bFloor) * x^power[site])
//      + bSiteYear[site, year]
//   x           = diameter / diameter_ref
//   power[site] = bPower * exp(bSitePower[site])
//
// The mean function is Packard's (2012) three-parameter power form, W = Y0 + a*D^b,
// reparameterised on the diameter ratio so the reference weight stays comparable.
// bFloor on (0, 1) is the share of expected weight at diameter_ref that is
// size-independent, which is what makes the floor estimable when no plant with zero
// measurable sub-bulb is ever harvested; bFloor = 0 collapses to a power law. It
// replaces a quadratic in log diameter, whose exponent crossed zero below the
// harvested range, so predicted weight rose as diameter fell past the turning point.
// Packard's floor is monotone by construction.
//
// The population exponent bPower is positive and the site effect is a log-scale
// multiplier, so power[site] > 0 always and monotonicity holds within every site.
// Keeping bPower on the natural scale means its prior and its tidy() row are the
// allometric exponent itself, with no back-transform for a reader to remember.
//
// log-diameter is centered at diameter_ref (passed as data: the geometric mean of
// the observed diameter), so the diameter unit does not affect the fit, and the
// centering also bounds power * log_diameter, which is what lets the mean be
// written as a plain log(...) without a log_sum_exp pivot for numerical safety.
//
// Random effects: year, site intercept, site exponent, and site:year.
// Priors are passed as data; the prior family is fixed at compile time.
// The mean is computed with vectorised indexing (no per-observation loop) for a
// smaller autodiff graph, as a local in the model block so it is not saved with
// the draws. The pointwise log-likelihood and posterior-predictive replicates are
// computed in R from the stored draws, so there are no generated quantities.
data {
  int<lower=0> nObs;                      // 0 allowed: supports prior-only / empty fits
  int<lower=1> nSite;
  int<lower=1> nYear;
  array[nObs] int<lower=1, upper=nSite> site;
  array[nObs] int<lower=1, upper=nYear> year;
  vector<lower=0>[nObs] diameter;
  vector<lower=0>[nObs] weight;
  real<lower=0> diameter_ref;             // log-diameter centering reference

  // priors (hyperparameters passed as data)
  real prior_intercept_mu;
  real<lower=0> prior_intercept_sd;
  real prior_power_mu;                    // on bPower itself (truncated at 0 below)
  real<lower=0> prior_power_sd;
  real<lower=0> prior_floor_shape1;       // beta
  real<lower=0> prior_floor_shape2;
  real<lower=0> prior_nu_shape;           // gamma
  real<lower=0> prior_nu_rate;
  real<lower=0> prior_sd_site_rate;
  real<lower=0> prior_sd_year_rate;
  real<lower=0> prior_sd_site_power_rate;
  real<lower=0> prior_sd_site_year_rate;
  real<lower=0> prior_sd_residual_rate;

  int<lower=0, upper=1> prior_only;       // 1 = skip likelihood, sample from priors
  int<lower=0, upper=1> site_year_on;     // 0 = drop the site:year term (set to 0)
}
transformed data {
  real log_diameter_ref = log(diameter_ref);
  vector[nObs] log_diameter = log(diameter) - log_diameter_ref;
  vector[nObs] log_weight = log(weight);
  // column-major linear index into to_vector(bSiteYear): (site, year) ->
  // site + (year - 1) * nSite. Lets the site:year term be one vectorised gather.
  array[nObs] int sy_idx;
  for (i in 1:nObs) {
    sy_idx[i] = site[i] + (year[i] - 1) * nSite;
  }
}
parameters {
  real bWeight;                           // intercept: expected log(weight) at diameter_ref
  real<lower=0> bPower;                   // population allometric exponent
  real<lower=0, upper=1> bFloor;          // size-independent share of the reference weight
  real<lower=2> bNu;                      // Student-t degrees of freedom (estimated)
  real<lower=0> sSite;                    // site intercept SD
  real<lower=0> sYear;                    // year SD
  real<lower=0> sSitePower;               // SD of the log-scale site exponent multiplier
  real<lower=0> sSiteYear;                // site:year SD
  real<lower=0> sWeight;                  // residual scale
  vector[nSite] z_bSite;                  // non-centered site intercepts
  vector[nYear] z_bYear;                  // non-centered year effects
  vector[nSite] z_bSitePower;             // non-centered site exponents
  matrix[nSite, nYear] z_bSiteYear;       // non-centered site:year effects
}
transformed parameters {
  vector[nSite] bSite = z_bSite * sSite;
  vector[nYear] bYear = z_bYear * sYear;
  vector[nSite] bSitePower = z_bSitePower * sSitePower;
  matrix[nSite, nYear] bSiteYear = z_bSiteYear * sSiteYear;
}
model {
  bWeight ~ normal(prior_intercept_mu, prior_intercept_sd);
  // <lower=0> plus fixed hyperparameters makes this a truncated normal whose
  // normalising constant does not depend on any parameter, so no T[0,] is needed.
  bPower ~ normal(prior_power_mu, prior_power_sd);
  bFloor ~ beta(prior_floor_shape1, prior_floor_shape2);
  bNu ~ gamma(prior_nu_shape, prior_nu_rate);
  sSite ~ exponential(prior_sd_site_rate);
  sYear ~ exponential(prior_sd_year_rate);
  sSitePower ~ exponential(prior_sd_site_power_rate);
  sSiteYear ~ exponential(prior_sd_site_year_rate);
  sWeight ~ exponential(prior_sd_residual_rate);
  z_bSite ~ std_normal();
  z_bYear ~ std_normal();
  z_bSitePower ~ std_normal();
  to_vector(z_bSiteYear) ~ std_normal();
  if (prior_only == 0) {
    // Vectorised mean: gather random effects by observation, combine elementwise.
    // A local, not a transformed parameter: rstan saves transformed parameters,
    // and nObs columns per draw is the largest thing in a stored fit. Predictions
    // and the pointwise log-likelihood are computed in R from the stored draws.
    vector[nObs] power_obs = bPower * exp(bSitePower[site]);
    vector[nObs] log_eWeight = bWeight + bYear[year] + bSite[site]
      + log(bFloor + (1 - bFloor) * exp(power_obs .* log_diameter))
      + site_year_on * to_vector(bSiteYear)[sy_idx];
    log_weight ~ student_t(bNu, log_eWeight, sWeight);
  }
}
