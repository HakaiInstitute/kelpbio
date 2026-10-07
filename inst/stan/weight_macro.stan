// Macrocystis plant-level allometric weight model (site-year resolution).
// weight_kg ~ gamma(shape, shape / mu) where
//   mu = exp(intercept + site_effect[site]
//            + fronds_slope * log(fronds / fronds_ref)
//            + year_effect[year]
//            + site_year_effect[site, year])
// Constant Gamma shape (CV = 1/sqrt(shape), the same for every plant);
// there is no residual SD parameter.
// log-fronds is centred at fronds_ref (passed as data: the geometric mean of
// the observed frond count). Random effects: site intercept, year intercept, and
// site:year. Priors are passed as data; the prior family is fixed at compile
// time. The mean is a local in the model block so it is not saved with the draws.
// The pointwise log-likelihood and posterior-predictive replicates are computed
// in R from the stored draws, so there are no generated quantities.
data {
  int<lower=0> n_obs;                     // 0 allowed: supports prior-only / empty fits
  int<lower=1> n_site;
  int<lower=1> n_year;
  array[n_obs] int<lower=1, upper=n_site> site;
  array[n_obs] int<lower=1, upper=n_year> year;
  vector<lower=0>[n_obs] fronds;
  vector<lower=0>[n_obs] weight_kg;
  real<lower=0> fronds_ref;               // log-fronds centring reference

  // priors (hyperparameters passed as data)
  real prior_intercept_mean;
  real<lower=0> prior_intercept_sd;
  real prior_fronds_slope_mean;
  real<lower=0> prior_fronds_slope_sd;
  real<lower=0> prior_shape_rate;
  real<lower=0> prior_sd_site_rate;
  real<lower=0> prior_sd_year_rate;
  real<lower=0> prior_sd_site_year_rate;

  int<lower=0, upper=1> prior_only;       // 1 = skip likelihood, sample from priors
  int<lower=0, upper=1> site_year_on;     // 0 = drop the site:year term
}
transformed data {
  real log_fronds_ref = log(fronds_ref);
  vector[n_obs] log_fronds = log(fronds) - log_fronds_ref;
}
parameters {
  real intercept;                         // expected log(weight) at fronds_ref
  real fronds_slope;                      // log-fronds slope
  real<lower=0> shape;                    // Gamma shape
  real<lower=0> sd_site;                  // site intercept SD
  real<lower=0> sd_year;                  // year intercept SD
  real<lower=0> sd_site_year;             // site:year SD
  vector[n_site] z_site;                  // non-centred site intercepts
  vector[n_year] z_year;                  // non-centred year intercepts
  matrix[n_site, n_year] z_site_year;     // non-centred site:year effects
}
transformed parameters {
  vector[n_site] site_effect = z_site * sd_site;
  vector[n_year] year_effect = z_year * sd_year;
  matrix[n_site, n_year] site_year_effect = z_site_year * sd_site_year;
}
model {
  intercept ~ normal(prior_intercept_mean, prior_intercept_sd);
  fronds_slope ~ normal(prior_fronds_slope_mean, prior_fronds_slope_sd);
  shape ~ exponential(prior_shape_rate);
  sd_site ~ exponential(prior_sd_site_rate);
  sd_year ~ exponential(prior_sd_year_rate);
  sd_site_year ~ exponential(prior_sd_site_year_rate);
  z_site ~ std_normal();
  z_year ~ std_normal();
  to_vector(z_site_year) ~ std_normal();
  if (prior_only == 0) {
    // A local, not a transformed parameter: rstan saves transformed parameters,
    // and n_obs columns per draw is the largest thing in a stored fit. Predictions
    // and the pointwise log-likelihood are computed in R from the stored draws.
    vector[n_obs] log_mu;
    for (i in 1:n_obs) {
      log_mu[i] = intercept + site_effect[site[i]]
        + fronds_slope * log_fronds[i]
        + year_effect[year[i]]
        + site_year_on * site_year_effect[site[i], year[i]];
    }
    for (i in 1:n_obs) {
      real rate_i = shape / exp(log_mu[i]);
      weight_kg[i] ~ gamma(shape, rate_i);
    }
  }
}
