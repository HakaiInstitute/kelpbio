// Macrocystis plant-level allometric weight model (site-year resolution).
// weight ~ gamma(shape, shape / eWeight) where
//   eWeight = exp(bWeight + bSite[site]
//                 + bFronds * log(fronds / fronds_ref)
//                 + bYear[year]
//                 + bSiteYear[site, year])
// Constant Gamma shape (CV = 1/sqrt(shape), the same for every plant);
// there is no residual SD parameter.
// log-fronds is centered at fronds_ref (passed as data: the geometric mean of
// the observed frond count). Random effects: site intercept, year intercept, and
// site:year. Priors are passed as data; the prior family is fixed at compile
// time.
data {
  int<lower=0> nObs;                      // 0 allowed: supports prior-only / empty fits
  int<lower=1> nSite;
  int<lower=1> nYear;
  array[nObs] int<lower=1, upper=nSite> site;
  array[nObs] int<lower=1, upper=nYear> year;
  vector<lower=0>[nObs] fronds;
  vector<lower=0>[nObs] weight;
  real<lower=0> fronds_ref;               // log-fronds centering reference

  // priors (hyperparameters passed as data)
  real prior_intercept_mu;
  real<lower=0> prior_intercept_sd;
  real prior_fronds_mu;
  real<lower=0> prior_fronds_sd;
  real<lower=0> prior_shape_rate;
  real<lower=0> prior_sd_site_rate;
  real<lower=0> prior_sd_year_rate;
  real<lower=0> prior_sd_site_year_rate;

  int<lower=0, upper=1> prior_only;       // 1 = skip likelihood, sample from priors
  int<lower=0, upper=1> site_year_on;     // 0 = drop the site:year term
}
transformed data {
  real log_fronds_ref = log(fronds_ref);
  vector[nObs] log_fronds = log(fronds) - log_fronds_ref;
}
parameters {
  real bWeight;                           // intercept: expected log(weight) at fronds_ref
  real bFronds;                           // log-fronds slope
  real<lower=0> shape;                    // Gamma shape (dispersion)
  real<lower=0> sSite;                    // site intercept SD
  real<lower=0> sYear;                    // year intercept SD
  real<lower=0> sSiteYear;                // site:year SD
  vector[nSite] z_bSite;                  // non-centered site intercepts
  vector[nYear] z_bYear;                  // non-centered year intercepts
  matrix[nSite, nYear] z_bSiteYear;       // non-centered site:year effects
}
transformed parameters {
  vector[nSite] bSite = z_bSite * sSite;
  vector[nYear] bYear = z_bYear * sYear;
  matrix[nSite, nYear] bSiteYear = z_bSiteYear * sSiteYear;
  vector[nObs] log_eWeight;
  for (i in 1:nObs) {
    log_eWeight[i] = bWeight + bSite[site[i]]
      + bFronds * log_fronds[i]
      + bYear[year[i]]
      + site_year_on * bSiteYear[site[i], year[i]];
  }
}
model {
  bWeight ~ normal(prior_intercept_mu, prior_intercept_sd);
  bFronds ~ normal(prior_fronds_mu, prior_fronds_sd);
  shape ~ exponential(prior_shape_rate);
  sSite ~ exponential(prior_sd_site_rate);
  sYear ~ exponential(prior_sd_year_rate);
  sSiteYear ~ exponential(prior_sd_site_year_rate);
  z_bSite ~ std_normal();
  z_bYear ~ std_normal();
  to_vector(z_bSiteYear) ~ std_normal();
  if (prior_only == 0) {
    for (i in 1:nObs) {
      real rate_i = shape / exp(log_eWeight[i]);
      weight[i] ~ gamma(shape, rate_i);
    }
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
    real rate_i = shape / exp(log_eWeight[i]);
    log_lik[i] = gamma_lpdf(weight[i] | shape, rate_i);
    yrep[i] = gamma_rng(shape, rate_i);
  }
}
