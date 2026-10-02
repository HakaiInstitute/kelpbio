// Wet/dry mass ratio, shared by both species: the dry:wet mass ratio of a tissue
// sample follows a Beta distribution parameterised by its mean and precision.
//   ratio ~ beta(mu * bPrecision, (1 - mu) * bPrecision)
//   logit(mu) = bDryWet
// mu is the mean ratio and bPrecision the precision (larger means less spread
// around mu). There are no random effects: samples are pooled over the months,
// sites, and tissues they come from. Priors are passed as data; the prior family
// is fixed at compile time. The pointwise log-likelihood and posterior-predictive
// replicates are computed in R from the stored draws, so there are no generated
// quantities.
data {
  int<lower=0> nObs;                      // 0 allowed: supports prior-only / empty fits
  vector<lower=0, upper=1>[nObs] ratio;   // dry mass / wet mass

  // priors (hyperparameters passed as data)
  real prior_intercept_mu;
  real<lower=0> prior_intercept_sd;
  real<lower=0> prior_precision_rate;

  int<lower=0, upper=1> prior_only;       // 1 = skip likelihood, sample from priors
}
parameters {
  real bDryWet;                           // logit mean dry:wet ratio
  real<lower=0> bPrecision;               // Beta precision
}
model {
  bDryWet ~ normal(prior_intercept_mu, prior_intercept_sd);
  bPrecision ~ exponential(prior_precision_rate);
  if (prior_only == 0) {
    real mu = inv_logit(bDryWet);
    ratio ~ beta(mu * bPrecision, (1 - mu) * bPrecision);
  }
}
