// Carbon fraction of dry mass, shared by both species: the fraction of a dried
// tissue sample's mass that is carbon follows a Beta distribution parameterised
// by its mean and precision.
//   carbon_fraction ~ beta(mu * bPrecision, (1 - mu) * bPrecision)
//   logit(mu) = bCarbon
// mu is the mean fraction and bPrecision the precision (larger means less spread
// around mu). There are no random effects: samples are pooled over the months,
// sites, and tissues they come from. Priors are passed as data; the prior family
// is fixed at compile time. The pointwise log-likelihood and posterior-predictive
// replicates are computed in R from the stored draws, so there are no generated
// quantities.
data {
  int<lower=0> nObs;                      // 0 allowed: supports prior-only / empty fits
  vector<lower=0, upper=1>[nObs] carbon_fraction;

  // priors (hyperparameters passed as data)
  real prior_intercept_mu;
  real<lower=0> prior_intercept_sd;
  real<lower=0> prior_precision_rate;

  int<lower=0, upper=1> prior_only;       // 1 = skip likelihood, sample from priors
}
parameters {
  real bCarbon;                           // logit mean carbon fraction
  real<lower=0> bPrecision;               // Beta precision
}
model {
  bCarbon ~ normal(prior_intercept_mu, prior_intercept_sd);
  bPrecision ~ exponential(prior_precision_rate);
  if (prior_only == 0) {
    real mu = inv_logit(bCarbon);
    carbon_fraction ~ beta(mu * bPrecision, (1 - mu) * bPrecision);
  }
}
