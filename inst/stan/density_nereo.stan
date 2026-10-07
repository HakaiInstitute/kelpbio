// Nereocystis stipe density (site-year resolution): the number of stipes on a
// transect follows a zero-inflated negative binomial, with the transect area as
// an offset.
//   stipes ~ ZINB(area_m2 * exp(log_density), 1 / dispersion, zi)
//   log_density = intercept + site_effect[site] + year_effect[year]
//                 + site_year_effect[site, year]
//   zi = inv_logit(logit_zero_inflation)
// zi is the probability that a transect holds no stipes, one value for all
// transects; exp(log_density) is the density (stipes per m^2) on transects that
// hold stipes, so the expected count is (1 - zi) * area_m2 * exp(log_density).
// Random effects: site, year, and site:year, all on log_density. Priors are
// passed as data; the prior family is fixed at compile time. The mean is a local
// in the model block so it is not saved with the draws. The pointwise
// log-likelihood and posterior-predictive replicates are computed in R from the
// stored draws, so there are no generated quantities.
functions {
  int count_zeros(array[] int y) {
    int n = 0;
    for (i in 1:size(y)) {
      n += (y[i] == 0);
    }
    return n;
  }
}
data {
  int<lower=0> n_obs;                     // 0 allowed: supports prior-only / empty fits
  int<lower=1> n_site;
  int<lower=1> n_year;
  array[n_obs] int<lower=1, upper=n_site> site;
  array[n_obs] int<lower=1, upper=n_year> year;
  array[n_obs] int<lower=0> stipes;
  vector<lower=0>[n_obs] area_m2;         // area surveyed (m^2)

  // priors (hyperparameters passed as data)
  real prior_intercept_mean;
  real<lower=0> prior_intercept_sd;
  real prior_logit_zero_inflation_mean;
  real<lower=0> prior_logit_zero_inflation_sd;
  real<lower=0> prior_dispersion_rate;
  real<lower=0> prior_sd_site_rate;
  real<lower=0> prior_sd_year_rate;
  real<lower=0> prior_sd_site_year_rate;

  int<lower=0, upper=1> prior_only;       // 1 = skip likelihood, sample from priors
  int<lower=0, upper=1> site_year_on;     // 0 = drop the site:year term
}
transformed data {
  vector[n_obs] log_area = log(area_m2);
  // column-major linear index into to_vector(site_year_effect): (site, year) ->
  // site + (year - 1) * n_site. Lets the site:year term be one vectorised gather.
  array[n_obs] int sy_idx;
  // Zero and non-zero counts take different likelihood terms, so their indices
  // are split once here and each term is vectorised.
  int n_zero = count_zeros(stipes);
  array[n_zero] int idx_zero;
  array[n_obs - n_zero] int idx_pos;
  {
    int iz = 1;
    int ip = 1;
    for (i in 1:n_obs) {
      sy_idx[i] = site[i] + (year[i] - 1) * n_site;
      if (stipes[i] == 0) {
        idx_zero[iz] = i;
        iz += 1;
      } else {
        idx_pos[ip] = i;
        ip += 1;
      }
    }
  }
}
parameters {
  real intercept;                         // log stipes per m^2 at a typical site and year
  real logit_zero_inflation;              // logit probability a transect holds no stipes
  real<lower=0> dispersion;               // overdispersion; phi = 1 / dispersion
  real<lower=0> sd_site;                  // site SD
  real<lower=0> sd_year;                  // year SD
  real<lower=0> sd_site_year;             // site:year SD
  vector[n_site] z_site;                  // non-centered site effects
  vector[n_year] z_year;                  // non-centered year effects
  matrix[n_site, n_year] z_site_year;     // non-centered site:year effects
}
transformed parameters {
  vector[n_site] site_effect = z_site * sd_site;
  vector[n_year] year_effect = z_year * sd_year;
  matrix[n_site, n_year] site_year_effect = z_site_year * sd_site_year;
}
model {
  intercept ~ normal(prior_intercept_mean, prior_intercept_sd);
  logit_zero_inflation ~ normal(prior_logit_zero_inflation_mean, prior_logit_zero_inflation_sd);
  dispersion ~ exponential(prior_dispersion_rate);
  sd_site ~ exponential(prior_sd_site_rate);
  sd_year ~ exponential(prior_sd_year_rate);
  sd_site_year ~ exponential(prior_sd_site_year_rate);
  z_site ~ std_normal();
  z_year ~ std_normal();
  to_vector(z_site_year) ~ std_normal();
  if (prior_only == 0) {
    // A local, not a transformed parameter: rstan saves transformed parameters,
    // and n_obs columns per draw is the largest thing in a stored fit.
    real phi = 1 / dispersion;
    real log_zi = log_inv_logit(logit_zero_inflation);
    real log1m_zi = log1m_inv_logit(logit_zero_inflation);
    vector[n_obs] log_mu = log_area + intercept + site_effect[site] + year_effect[year]
      + site_year_on * to_vector(site_year_effect)[sy_idx];
    // A zero is structural or a negative binomial zero:
    // log(zi + (1 - zi) * P0) = log(zi) + log1p(exp(log(1 - zi) + log(P0) - log(zi))),
    // with log P0 = -phi * log(1 + mu / phi) written on the log scale for stability.
    vector[n_zero] log_p0 = -phi * log1p_exp(log_mu[idx_zero] - log(phi));
    target += n_zero * log_zi + sum(log1p_exp(log1m_zi + log_p0 - log_zi));
    target += (n_obs - n_zero) * log1m_zi
      + neg_binomial_2_log_lpmf(stipes[idx_pos] | log_mu[idx_pos], phi);
  }
}
