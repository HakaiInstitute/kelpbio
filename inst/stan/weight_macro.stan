// Macrocystis weight: Gamma with a constant shape, log-linear in log fronds.
//   weight_kg ~ gamma(shape, shape / mu)
//   log(mu) = intercept + fronds_slope * log(fronds / fronds_ref)
//             + site_effect[site] + year_effect[year]
//             + site_year_on * site_year_effect[site, year]
data {
  int<lower=0> n_obs;
  int<lower=1> n_site;
  int<lower=1> n_year;
  array[n_obs] int<lower=1, upper=n_site> site;
  array[n_obs] int<lower=1, upper=n_year> year;
  vector<lower=0>[n_obs] fronds;
  vector<lower=0>[n_obs] weight_kg;
  real<lower=0> fronds_ref;               // geometric mean frond count

  real prior_intercept_mean;
  real<lower=0> prior_intercept_sd;
  real prior_fronds_slope_mean;
  real<lower=0> prior_fronds_slope_sd;
  real<lower=0> prior_shape_rate;
  real<lower=0> prior_sd_site_rate;
  real<lower=0> prior_sd_year_rate;
  real<lower=0> prior_sd_site_year_rate;

  int<lower=0, upper=1> prior_only;
  int<lower=0, upper=1> site_year_on;
}
transformed data {
  vector[n_obs] log_fronds = log(fronds) - log(fronds_ref);
  // index of (site, year) in to_vector(site_year_effect)
  array[n_obs] int sy_idx;
  for (i in 1:n_obs) {
    sy_idx[i] = site[i] + (year[i] - 1) * n_site;
  }
}
parameters {
  real intercept;                         // log expected weight at fronds_ref
  real fronds_slope;
  real<lower=0> shape;
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
  fronds_slope ~ normal(prior_fronds_slope_mean, prior_fronds_slope_sd);
  shape ~ exponential(prior_shape_rate);
  sd_site ~ exponential(prior_sd_site_rate);
  sd_year ~ exponential(prior_sd_year_rate);
  sd_site_year ~ exponential(prior_sd_site_year_rate);
  z_site ~ std_normal();
  z_year ~ std_normal();
  to_vector(z_site_year) ~ std_normal();
  if (prior_only == 0) {
    vector[n_obs] log_mu = intercept + fronds_slope * log_fronds
      + site_effect[site] + year_effect[year]
      + site_year_on * to_vector(site_year_effect)[sy_idx];
    weight_kg ~ gamma(shape, shape * exp(-log_mu));
  }
}
