// Full allometric weight model (site-year resolution).
// log(weight) ~ normal(log(eWeight), sWeight) where
//   eWeight    = bFloor + alpha * x^bPower
//   log(alpha) = bWeight + bDensity * density + bYear[year] + bSite[site]
//                + bSiteYear[site, year]
//   x          = diameter / diameter_ref
//
// The mean function is Packard's (2023) three-parameter power function,
// W = a + b * D^c, with diameter expressed relative to a reference so that alpha
// is the weight above the floor at diameter_ref. bFloor is the weight floor, in
// the units of weight, as diameter approaches zero, and bPower the allometric
// scaling exponent; neither depends on diameter_ref. The implied log-log slope,
// bPower * (eWeight - bFloor) / eWeight, is increasing and bounded in (0, bPower),
// so expected weight is monotone in diameter.
//
// floor_on = 0 drops the floor (the "power" form), giving the power law
// eWeight = alpha * x^bPower, linear on log-log axes.
//
// The random effects act on alpha, not on the whole expectation: they scale the
// size-dependent part of the weight and leave the floor common, since the floor
// reflects which small plants are harvested rather than site condition.
//
// Gaussian on log weight, not Student-t: a Student-t has no finite exponential
// moment, so E[weight | diameter] would not exist and weight could not be
// averaged over the size distribution for biomass.
//
// diameter_ref is passed as data (the geometric mean of the observed diameter),
// so alpha is the weight at a typical plant and bWeight and bPower are close to
// uncorrelated in the posterior.
//
// density is the site-year stipe density, standardised in R (0 = the mean over
// the fitted plants, also used where a site-year has no recorded density).
//
// Random effects: year, site, and site:year, all on log(alpha).
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
  real<lower=0> diameter_ref;             // diameter reference for x
  vector[nObs] density;                   // standardised site-year stipe density

  // priors (hyperparameters passed as data)
  real prior_intercept_mu;
  real<lower=0> prior_intercept_sd;
  real prior_power_mu;                    // on bPower (truncated at 0 below)
  real<lower=0> prior_power_sd;
  real prior_floor_mu;                    // on bFloor (truncated at 0 below)
  real<lower=0> prior_floor_sd;
  real prior_density_mu;
  real<lower=0> prior_density_sd;
  real<lower=0> prior_sd_site_rate;
  real<lower=0> prior_sd_year_rate;
  real<lower=0> prior_sd_site_year_rate;
  real<lower=0> prior_sd_residual_rate;

  int<lower=0, upper=1> prior_only;       // 1 = skip likelihood, sample from priors
  int<lower=0, upper=1> site_year_on;     // 0 = drop the site:year term (set to 0)
  int<lower=0, upper=1> density_on;       // 0 = drop the density term
  int<lower=0, upper=1> floor_on;         // 0 = drop the floor (power-law form)
}
transformed data {
  vector[nObs] log_x = log(diameter) - log(diameter_ref);
  vector[nObs] log_weight = log(weight);
  // column-major linear index into to_vector(bSiteYear): (site, year) ->
  // site + (year - 1) * nSite. Lets the site:year term be one vectorised gather.
  array[nObs] int sy_idx;
  for (i in 1:nObs) {
    sy_idx[i] = site[i] + (year[i] - 1) * nSite;
  }
}
parameters {
  real bWeight;                           // log(alpha) at a typical site and year
  real<lower=0> bPower;                   // allometric scaling exponent
  real<lower=0> bFloor;                   // weight floor as diameter approaches zero
  real bDensity;                          // effect of standardised density on log(alpha)
  real<lower=0> sSite;                    // site SD
  real<lower=0> sYear;                    // year SD
  real<lower=0> sSiteYear;                // site:year SD
  real<lower=0> sWeight;                  // residual SD of log weight
  vector[nSite] z_bSite;                  // non-centered site effects
  vector[nYear] z_bYear;                  // non-centered year effects
  matrix[nSite, nYear] z_bSiteYear;       // non-centered site:year effects
}
transformed parameters {
  vector[nSite] bSite = z_bSite * sSite;
  vector[nYear] bYear = z_bYear * sYear;
  matrix[nSite, nYear] bSiteYear = z_bSiteYear * sSiteYear;
}
model {
  bWeight ~ normal(prior_intercept_mu, prior_intercept_sd);
  // <lower=0> plus fixed hyperparameters makes these truncated normals whose
  // normalising constants do not depend on any parameter, so no T[0,] is needed.
  bPower ~ normal(prior_power_mu, prior_power_sd);
  bFloor ~ normal(prior_floor_mu, prior_floor_sd);
  bDensity ~ normal(prior_density_mu, prior_density_sd);
  sSite ~ exponential(prior_sd_site_rate);
  sYear ~ exponential(prior_sd_year_rate);
  sSiteYear ~ exponential(prior_sd_site_year_rate);
  sWeight ~ exponential(prior_sd_residual_rate);
  z_bSite ~ std_normal();
  z_bYear ~ std_normal();
  to_vector(z_bSiteYear) ~ std_normal();
  if (prior_only == 0) {
    // Vectorised mean: gather random effects by observation, combine elementwise.
    // A local, not a transformed parameter: rstan saves transformed parameters,
    // and nObs columns per draw is the largest thing in a stored fit. Predictions
    // and the pointwise log-likelihood are computed in R from the stored draws.
    vector[nObs] log_alpha = bWeight + density_on * bDensity * density
      + bYear[year] + bSite[site]
      + site_year_on * to_vector(bSiteYear)[sy_idx];
    vector[nObs] log_eWeight = log(floor_on * bFloor + exp(log_alpha + bPower * log_x));
    log_weight ~ normal(log_eWeight, sWeight);
  }
}
