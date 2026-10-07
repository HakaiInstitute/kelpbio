// Macrocystis density: plants per transect are negative binomial, with the
// transect area as an offset.
//   plants ~ neg_binomial_2(area_m2 * exp(log_density), 1 / dispersion)
//   log_density = intercept + site_effect[site] + year_effect[year]
//                 + site_year_on * site_year_effect[site, year]
data {
  int<lower=0> n_obs;
  int<lower=1> n_site;
  int<lower=1> n_year;
  array[n_obs] int<lower=1, upper=n_site> site;
  array[n_obs] int<lower=1, upper=n_year> year;
  array[n_obs] int<lower=0> plants;
  vector<lower=0>[n_obs] area_m2;

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
  vector[n_obs] log_area = log(area_m2);
  // index of (site, year) in to_vector(site_year_effect)
  array[n_obs] int sy_idx;
  for (i in 1:n_obs) {
    sy_idx[i] = site[i] + (year[i] - 1) * n_site;
  }
}
parameters {
  real intercept;                         // log plants per m^2 at a typical site and year
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
    vector[n_obs] log_mu = log_area + intercept + site_effect[site] + year_effect[year]
      + site_year_on * to_vector(site_year_effect)[sy_idx];
    plants ~ neg_binomial_2_log(log_mu, 1 / dispersion);
  }
}
