// Cover calibration, both species: the wet biomass of an in situ survey
// (kg/m^2) is a floor plus a term proportional to its plot's tide-corrected
// canopy cover.
//   biomass ~ normal(mu, sigma), censored below at 0
//   mu = biomass_floor + cover_slope * exp(site_effect[site] + year_effect[year]) * cover
//   sigma = sqrt(sd_residual^2 + (cv_residual * mu)^2 + biomass_sd^2)
//   seen = 1 - tide_height_slope * tide_height_m
//   cover = 0                                            if canopy_area_m2 = 0
//         = min(plot_area_m2, canopy_area_m2 / seen) / plot_area_m2   if seen > 0
//         = 1                                            otherwise
// Past one over the slope (seen <= 0) the division has no finite value, so a
// plot with canopy takes the limit of the capped value, full cover.
// tide_height_slope is the share of the zero-tide canopy lost per metre of
// tide. biomass_sd is each survey's SD from plant weight (the count is a census
// of the surveyed area). A survey with nothing counted enters as the
// probability of a value at or below zero. The group effects scale the canopy
// term only.
data {
  int<lower=0> n_obs;
  int<lower=1> n_site;
  int<lower=1> n_year;
  array[n_obs] int<lower=1, upper=n_site> site;
  array[n_obs] int<lower=1, upper=n_year> year;
  vector<lower=0>[n_obs] canopy_area_m2;
  vector<lower=0>[n_obs] plot_area_m2;
  vector[n_obs] tide_height_m;
  vector<lower=0>[n_obs] biomass;          // mean survey wet biomass (kg/m^2)
  vector<lower=0>[n_obs] biomass_sd;
  array[n_obs] int<lower=0, upper=1> zero;

  real prior_cover_slope_meanlog;
  real<lower=0> prior_cover_slope_sdlog;
  real prior_biomass_floor_mean;
  real<lower=0> prior_biomass_floor_sd;
  real prior_tide_height_slope_mean;
  real<lower=0> prior_tide_height_slope_sd;
  real<lower=0> prior_sd_residual_rate;
  real prior_cv_residual_mean;
  real<lower=0> prior_cv_residual_sd;
  real<lower=0> prior_sd_site_rate;
  real<lower=0> prior_sd_year_rate;

  int<lower=0, upper=1> prior_only;
}
parameters {
  real<lower=0> cover_slope;              // kg per m^2 of canopy, typical site and year
  real<lower=0> biomass_floor;            // kg/m^2 at zero cover
  real<lower=0, upper=0.5> tide_height_slope;
  real<lower=0> sd_residual;              // constant residual SD (kg/m^2)
  real<lower=0> cv_residual;              // residual SD per unit of mu
  real<lower=0> sd_site;
  real<lower=0> sd_year;
  vector[n_site] z_site;
  vector[n_year] z_year;
}
transformed parameters {
  vector[n_site] site_effect = z_site * sd_site;
  vector[n_year] year_effect = z_year * sd_year;
}
model {
  cover_slope ~ lognormal(prior_cover_slope_meanlog, prior_cover_slope_sdlog);
  biomass_floor ~ normal(prior_biomass_floor_mean, prior_biomass_floor_sd);
  tide_height_slope ~ normal(prior_tide_height_slope_mean, prior_tide_height_slope_sd);
  sd_residual ~ exponential(prior_sd_residual_rate);
  cv_residual ~ normal(prior_cv_residual_mean, prior_cv_residual_sd);
  sd_site ~ exponential(prior_sd_site_rate);
  sd_year ~ exponential(prior_sd_year_rate);
  z_site ~ std_normal();
  z_year ~ std_normal();
  if (prior_only == 0) {
    for (i in 1:n_obs) {
      real seen = 1 - tide_height_slope * tide_height_m[i];
      real cover = 0;
      if (canopy_area_m2[i] > 0) {
        cover = seen > 0
          ? fmin(plot_area_m2[i], canopy_area_m2[i] / seen) / plot_area_m2[i]
          : 1;
      }
      real mu = biomass_floor
        + cover_slope * exp(site_effect[site[i]] + year_effect[year[i]]) * cover;
      real sigma = sqrt(
        square(sd_residual) + square(cv_residual * mu) + square(biomass_sd[i])
      );
      if (zero[i] == 1) {
        target += normal_lcdf(0 | mu, sigma);
      } else {
        target += normal_lpdf(biomass[i] | mu, sigma);
      }
    }
  }
}
