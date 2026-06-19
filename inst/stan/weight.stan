// Full allometric weight model (site-year resolution).
// log(weight) ~ student_t(4, mu, sWeight) where
//   mu = bWeight30 + bSite[site]
//      + (bDiameter + bSiteDiameter[site]) * log(diameter / 30)
//      + bDiameter2 * log(diameter / 30)^2
//      + bSiteYear[site, year]
// Random effects: site intercept, site slope (on log diameter), and site:year.
// Priors are passed as data; the prior family is fixed at compile time.
data {
  int<lower=0> nObs;                      // 0 allowed: supports prior-only / empty fits
  int<lower=1> nSite;
  int<lower=1> nYear;
  array[nObs] int<lower=1, upper=nSite> site;
  array[nObs] int<lower=1, upper=nYear> year;
  vector<lower=0>[nObs] diameter;
  vector<lower=0>[nObs] weight;

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
}
transformed data {
  real nu = 4.0;                          // Student-t degrees of freedom (fixed)
  real log_diameter_ref = log(30);
  vector[nObs] log_diameter = log(diameter) - log_diameter_ref;
  vector[nObs] log_weight = log(weight);
}
parameters {
  real bWeight30;                         // intercept: expected log(weight) at diameter = 30
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
  vector[nObs] log_eWeight;
  for (i in 1:nObs) {
    log_eWeight[i] = bWeight30 + bSite[site[i]]
      + (bDiameter + bSiteDiameter[site[i]]) * log_diameter[i]
      + bDiameter2 * log_diameter[i]^2
      + bSiteYear[site[i], year[i]];
  }
}
model {
  bWeight30 ~ normal(prior_intercept_mu, prior_intercept_sd);
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
    log_weight ~ student_t(nu, log_eWeight, sWeight);
  }
}
generated quantities {
  // Reuse the single mean definition (log_eWeight, transformed parameters).
  // log_lik: pointwise log-likelihood, for loo.
  // yrep:    response-scale posterior-predictive replicate, for pp_check.
  // Both loops are no-ops when nObs == 0. Predictions at new data are computed
  // in R from the stored draws, not here.
  vector[nObs] log_lik;
  vector[nObs] yrep;
  for (i in 1:nObs) {
    log_lik[i] = student_t_lpdf(log_weight[i] | nu, log_eWeight[i], sWeight);
    yrep[i] = exp(student_t_rng(nu, log_eWeight[i], sWeight));
  }
}
