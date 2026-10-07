// Carbon fraction of dry mass, shared by both species: the fraction of a dried
// tissue sample's mass that is carbon follows a Beta distribution parameterised
// by its mean and precision.
//   carbon_fraction ~ beta(mu * precision, (1 - mu) * precision)
//   logit(mu) = intercept
// mu is the mean fraction and precision the precision (larger means less spread
// around mu). There are no random effects: samples are pooled over the months,
// sites, and tissues they come from. Priors are passed as data; the prior family
// is fixed at compile time. The pointwise log-likelihood and posterior-predictive
// replicates are computed in R from the stored draws, so there are no generated
// quantities.
data {
  int<lower=0> n_obs;                     // 0 allowed: supports prior-only / empty fits
  vector<lower=0, upper=1>[n_obs] carbon_fraction;

  // priors (hyperparameters passed as data)
  real prior_intercept_mean;
  real<lower=0> prior_intercept_sd;
  real<lower=0> prior_precision_rate;

  int<lower=0, upper=1> prior_only;       // 1 = skip likelihood, sample from priors
}
parameters {
  real intercept;                         // logit mean carbon fraction
  real<lower=0> precision;                // Beta precision
}
model {
  intercept ~ normal(prior_intercept_mean, prior_intercept_sd);
  precision ~ exponential(prior_precision_rate);
  if (prior_only == 0) {
    real mu = inv_logit(intercept);
    carbon_fraction ~ beta(mu * precision, (1 - mu) * precision);
  }
}
