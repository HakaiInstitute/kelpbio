// Dry:wet mass ratio, both species: Beta in its mean and precision, pooled over
// samples (no group effects).
//   dry_wet_ratio ~ beta(mu * precision, (1 - mu) * precision)
//   logit(mu) = intercept
data {
  int<lower=0> n_obs;
  vector<lower=0, upper=1>[n_obs] dry_wet_ratio; // dry mass / wet mass

  real prior_intercept_mean;
  real<lower=0> prior_intercept_sd;
  real<lower=0> prior_precision_rate;

  int<lower=0, upper=1> prior_only;
}
parameters {
  real intercept;                         // logit mean dry:wet ratio
  real<lower=0> precision;
}
model {
  intercept ~ normal(prior_intercept_mean, prior_intercept_sd);
  precision ~ exponential(prior_precision_rate);
  if (prior_only == 0) {
    real mu = inv_logit(intercept);
    dry_wet_ratio ~ beta(mu * precision, (1 - mu) * precision);
  }
}
