// Carbon fraction of dry mass, both species: Beta in its mean and precision,
// pooled over samples (no group effects).
//   carbon_fraction ~ beta(mu * precision, (1 - mu) * precision)
//   logit(mu) = intercept
data {
  int<lower=0> n_obs;
  vector<lower=0, upper=1>[n_obs] carbon_fraction;

  real prior_intercept_mean;
  real<lower=0> prior_intercept_sd;
  real<lower=0> prior_precision_rate;

  int<lower=0, upper=1> prior_only;
}
parameters {
  real intercept;                         // logit mean carbon fraction
  real<lower=0> precision;
}
model {
  intercept ~ normal(prior_intercept_mean, prior_intercept_sd);
  precision ~ exponential(prior_precision_rate);
  if (prior_only == 0) {
    real mu = inv_logit(intercept);
    carbon_fraction ~ beta(mu * precision, (1 - mu) * precision);
  }
}
