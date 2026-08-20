// Full allometric weight model (site-year resolution).
// log(weight) ~ student_t(4, mu, sWeight) where
//   mu = bWeight + bSite[site]
//      + (bDiameter + bSiteDiameter[site]) * log(diameter / diameter_ref)
//      + bDiameter2 * log(diameter / diameter_ref)^2
//      + bSiteYear[site, year]
// log-diameter is centered at diameter_ref (passed as data: the geometric mean
// of the observed diameter), so the diameter unit does not affect the fit.
// Random effects: site intercept, site slope (on log diameter), and site:year.
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
  real prior_diameter_mu;
  real<lower=0> prior_diameter_sd;
  real prior_diameter2_mu;
  real<lower=0> prior_diameter2_sd;
  real<lower=0> prior_sd_site_rate;
  real<lower=0> prior_sd_site_diameter_rate;
  real<lower=0> prior_sd_site_year_rate;
  real<lower=0> prior_sd_residual_rate;

  int<lower=0, upper=1> prior_only;       // 1 = skip likelihood, sample from priors
  int<lower=0, upper=1> site_year_on;     // 0 = drop the site:year term (set to 0)
}
transformed data {
  real nu = 4.0;                          // Student-t degrees of freedom (fixed)
  real log_diameter_ref = log(diameter_ref);
  vector[nObs] log_diameter = log(diameter) - log_diameter_ref;
  vector[nObs] log_diameter_sq = log_diameter .* log_diameter;  // precomputed
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
  real bDiameter;                         // linear log-diameter slope
  real bDiameter2;                        // quadratic log-diameter slope
  real<lower=0> sSite;                    // site intercept SD
  real<lower=0> sSiteDiameter;            // site slope SD
  real<lower=0> sSiteYear;                // site:year SD
  real<lower=0> sWeight;                  // residual scale
  vector[nSite] z_bSite;                  // non-centered site intercepts
  vector[nSite] z_bSiteDiameter;          // non-centered site slopes
  matrix[nSite, nYear] z_bSiteYear;       // non-centered site:year effects
}
transformed parameters {
  vector[nSite] bSite = z_bSite * sSite;
  vector[nSite] bSiteDiameter = z_bSiteDiameter * sSiteDiameter;
  matrix[nSite, nYear] bSiteYear = z_bSiteYear * sSiteYear;
}
model {
  bWeight ~ normal(prior_intercept_mu, prior_intercept_sd);
  bDiameter ~ normal(prior_diameter_mu, prior_diameter_sd);
  bDiameter2 ~ normal(prior_diameter2_mu, prior_diameter2_sd);
  sSite ~ exponential(prior_sd_site_rate);
  sSiteDiameter ~ exponential(prior_sd_site_diameter_rate);
  sSiteYear ~ exponential(prior_sd_site_year_rate);
  sWeight ~ exponential(prior_sd_residual_rate);
  z_bSite ~ std_normal();
  z_bSiteDiameter ~ std_normal();
  to_vector(z_bSiteYear) ~ std_normal();
  if (prior_only == 0) {
    // Vectorised mean: gather random effects by observation, combine elementwise.
    // A local, not a transformed parameter: rstan saves transformed parameters,
    // and nObs columns per draw is the largest thing in a stored fit. Predictions
    // and the pointwise log-likelihood are computed in R from the stored draws.
    vector[nObs] log_eWeight = bWeight + bSite[site]
      + (bDiameter + bSiteDiameter[site]) .* log_diameter
      + bDiameter2 * log_diameter_sq
      + site_year_on * to_vector(bSiteYear)[sy_idx];
    log_weight ~ student_t(nu, log_eWeight, sWeight);
  }
}
