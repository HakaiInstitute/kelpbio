// Macrocystis size: fronds reaching 1 m are zero-truncated negative binomial,
// since plants with none are not recorded.
//   fronds ~ neg_binomial_2(mu, 1 / dispersion) T[1, ]
//   log(mu) = intercept + site_effect[site] + year_effect[year]
//             + site_year_on * site_year_effect[site, year]
// mu is the mean before truncation.
data {
  int<lower=0> n_obs;
  int<lower=1> n_site;
  int<lower=1> n_year;
  array[n_obs] int<lower=1, upper=n_site> site;
  array[n_obs] int<lower=1, upper=n_year> year;
  array[n_obs] int<lower=1> fronds;

  real prior_intercept_mean;
  real<lower=0> prior_intercept_sd;
  real<lower=0> prior_dispersion_rate;
  real<lower=0> prior_sd_site_rate;
  real<lower=0> prior_sd_year_rate;
  real<lower=0> prior_sd_site_year_rate;

  int<lower=0, upper=1> prior_only;
  int<lower=0, upper=1> site_year_on;
}
transformed data {
  // index of (site, year) in to_vector(site_year_effect)
  array[n_obs] int sy_idx;
  for (i in 1:n_obs) {
    sy_idx[i] = site[i] + (year[i] - 1) * n_site;
  }
}
parameters {
  real intercept;                         // log mean frond count (before truncation)
  real<lower=0> dispersion;               // variance mu + dispersion * mu^2
  real<lower=0> sd_site;
  real<lower=0> sd_year;
  real<lower=0> sd_site_year;
  vector[n_site] z_site;
  vector[n_year] z_year;
  matrix[n_site, n_year] z_site_year;
}
transformed parameters {
  vector[n_site] site_effect = z_site * sd_site;
  vector[n_year] year_effect = z_year * sd_year;
  matrix[n_site, n_year] site_year_effect = z_site_year * sd_site_year;
}
model {
  intercept ~ normal(prior_intercept_mean, prior_intercept_sd);
  dispersion ~ exponential(prior_dispersion_rate);
  sd_site ~ exponential(prior_sd_site_rate);
  sd_year ~ exponential(prior_sd_year_rate);
  sd_site_year ~ exponential(prior_sd_site_year_rate);
  z_site ~ std_normal();
  z_year ~ std_normal();
  to_vector(z_site_year) ~ std_normal();
  if (prior_only == 0) {
    real phi = 1 / dispersion;
    vector[n_obs] log_mu = intercept + site_effect[site] + year_effect[year]
      + site_year_on * to_vector(site_year_effect)[sy_idx];
    // log P(0) = -phi * log(1 + mu / phi), written on the log scale for stability
    vector[n_obs] log_p0 = -phi * log1p_exp(log_mu - log(phi));
    target += neg_binomial_2_log_lpmf(fronds | log_mu, phi)
      - sum(log1m_exp(log_p0));
  }
}
