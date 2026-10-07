// Nereocystis weight: Packard's (2023) three-parameter power function.
//   log(weight_kg) ~ normal(log(mu), sd_residual)
//   mu         = floor_on * weight_floor + alpha * (diameter_mm / diameter_ref)^diameter_power
//   log(alpha) = intercept + density_on * density_slope * density
//                + site_effect[site] + year_effect[year]
//                + site_year_on * site_year_effect[site, year]
// The group effects act on alpha, so the floor is common to every site and year.
// Normal on log weight rather than Student-t, whose lack of a finite exponential
// moment would leave expected weight undefined.
data {
  int<lower=0> n_obs;
  int<lower=1> n_site;
  int<lower=1> n_year;
  array[n_obs] int<lower=1, upper=n_site> site;
  array[n_obs] int<lower=1, upper=n_year> year;
  vector<lower=0>[n_obs] diameter_mm;
  vector<lower=0>[n_obs] weight_kg;
  real<lower=0> diameter_ref;             // geometric mean diameter (mm)
  vector[n_obs] density;                  // standardised site-year stipe density

  real prior_intercept_mean;
  real<lower=0> prior_intercept_sd;
  real prior_diameter_power_mean;
  real<lower=0> prior_diameter_power_sd;
  real prior_weight_floor_mean;
  real<lower=0> prior_weight_floor_sd;
  real prior_density_slope_mean;
  real<lower=0> prior_density_slope_sd;
  real<lower=0> prior_sd_site_rate;
  real<lower=0> prior_sd_year_rate;
  real<lower=0> prior_sd_site_year_rate;
  real<lower=0> prior_sd_residual_rate;

  int<lower=0, upper=1> prior_only;
  int<lower=0, upper=1> site_year_on;
  int<lower=0, upper=1> density_on;
  int<lower=0, upper=1> floor_on;
}
transformed data {
  vector[n_obs] log_x = log(diameter_mm) - log(diameter_ref);
  vector[n_obs] log_weight = log(weight_kg);
  // index of (site, year) in to_vector(site_year_effect)
  array[n_obs] int sy_idx;
  for (i in 1:n_obs) {
    sy_idx[i] = site[i] + (year[i] - 1) * n_site;
  }
}
parameters {
  real intercept;
  real<lower=0> diameter_power;
  real<lower=0> weight_floor;             // weight (kg) as diameter approaches 0
  real density_slope;
  real<lower=0> sd_site;
  real<lower=0> sd_year;
  real<lower=0> sd_site_year;
  real<lower=0> sd_residual;
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
  // Truncated at 0 by the declarations, with constant normalising terms.
  diameter_power ~ normal(prior_diameter_power_mean, prior_diameter_power_sd);
  weight_floor ~ normal(prior_weight_floor_mean, prior_weight_floor_sd);
  density_slope ~ normal(prior_density_slope_mean, prior_density_slope_sd);
  sd_site ~ exponential(prior_sd_site_rate);
  sd_year ~ exponential(prior_sd_year_rate);
  sd_site_year ~ exponential(prior_sd_site_year_rate);
  sd_residual ~ exponential(prior_sd_residual_rate);
  z_site ~ std_normal();
  z_year ~ std_normal();
  to_vector(z_site_year) ~ std_normal();
  if (prior_only == 0) {
    vector[n_obs] log_alpha = intercept + density_on * density_slope * density
      + site_effect[site] + year_effect[year]
      + site_year_on * to_vector(site_year_effect)[sy_idx];
    vector[n_obs] log_mu = log(floor_on * weight_floor
      + exp(log_alpha + diameter_power * log_x));
    log_weight ~ normal(log_mu, sd_residual);
  }
}
