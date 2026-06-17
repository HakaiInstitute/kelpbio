// Site-intercept-only allometric weight model (vertical slice).
// log(weight) ~ student_t(4, bWeight30 + bSite[site] + bDiameter * log(diameter / 30), sWeight)
// Priors are passed as data; the prior family is fixed at compile time.
data {
  int<lower=0> nObs;                      // 0 allowed: supports prior-only / empty fits
  int<lower=1> nSite;
  array[nObs] int<lower=1, upper=nSite> site;
  vector<lower=0>[nObs] diameter;
  vector<lower=0>[nObs] weight;

  // priors (hyperparameters passed as data)
  real prior_intercept_mu;
  real<lower=0> prior_intercept_sd;
  real prior_slope_mu;
  real<lower=0> prior_slope_sd;
  real<lower=0> prior_sd_site_rate;
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
  real bDiameter;                         // fixed log-diameter slope
  real<lower=0> sSite;                    // site intercept SD
  real<lower=0> sWeight;                  // residual scale
  vector[nSite] z_bSite;                  // non-centered site intercepts
}
transformed parameters {
  vector[nSite] bSite = z_bSite * sSite;
  vector[nObs] log_eWeight;
  for (i in 1:nObs) {
    log_eWeight[i] = bWeight30 + bSite[site[i]] + bDiameter * log_diameter[i];
  }
}
model {
  bWeight30 ~ normal(prior_intercept_mu, prior_intercept_sd);
  bDiameter ~ normal(prior_slope_mu, prior_slope_sd);
  sSite ~ exponential(prior_sd_site_rate);
  sWeight ~ exponential(prior_sd_residual_rate);
  z_bSite ~ std_normal();
  if (prior_only == 0) {
    log_weight ~ student_t(nu, log_eWeight, sWeight);
  }
}
generated quantities {
  // Predicted weight at the observed grid on the response scale.
  // typical:  random effects zeroed (population-average relationship).
  // marginal: a new, unobserved site drawn from the site hyperprior.
  vector[nObs] typical;
  vector[nObs] marginal;
  for (i in 1:nObs) {
    real lp_typical = bWeight30 + bDiameter * log_diameter[i];
    typical[i] = exp(lp_typical);
    marginal[i] = exp(bWeight30 + normal_rng(0, sSite) + bDiameter * log_diameter[i]);
  }
}
