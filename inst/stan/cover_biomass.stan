// Cover biomass calibration, both species: in situ wet biomass (kg/m^2) is a
// floor plus a term proportional to tide-corrected canopy cover.
//   log_biomass ~ normal(log(mu), error_scaling * log_biomass_sd)
//   mu = biomass_floor + cover_slope * exp(site_effect[site] + year_effect[year]) * cover
//   cover = min(plot_area_m2, canopy_area_m2 * (1 + tide_height_slope * tide_height_m))
//           / plot_area_m2
// log_biomass_sd is each estimate's log-scale SD, so surveys are weighted by
// their precision and error_scaling calibrates it. The group effects scale the
// canopy term only.
data {
  int<lower=0> n_obs;
  int<lower=1> n_site;
  int<lower=1> n_year;
  array[n_obs] int<lower=1, upper=n_site> site;
  array[n_obs] int<lower=1, upper=n_year> year;
  vector<lower=0>[n_obs] canopy_area_m2;
  vector<lower=0>[n_obs] plot_area_m2;
  vector[n_obs] tide_height_m;
  vector[n_obs] log_biomass;              // log in situ wet biomass (kg/m^2)
  vector<lower=0>[n_obs] log_biomass_sd;

  real prior_cover_slope_meanlog;
  real<lower=0> prior_cover_slope_sdlog;
  real prior_biomass_floor_mean;
  real<lower=0> prior_biomass_floor_sd;
  real prior_tide_height_slope_mean;
  real<lower=0> prior_tide_height_slope_sd;
  real prior_error_scaling_mean;
  real<lower=0> prior_error_scaling_sd;
  real<lower=0> prior_sd_site_rate;
  real<lower=0> prior_sd_year_rate;

  int<lower=0, upper=1> prior_only;
}
parameters {
  real<lower=0> cover_slope;              // kg per m^2 of canopy, typical site and year
  real<lower=0> biomass_floor;            // kg/m^2 at zero cover
  real<lower=0> tide_height_slope;        // fractional canopy increase per m of tide
  real<lower=0> error_scaling;            // multiplier on log_biomass_sd
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
  error_scaling ~ normal(prior_error_scaling_mean, prior_error_scaling_sd);
  sd_site ~ exponential(prior_sd_site_rate);
  sd_year ~ exponential(prior_sd_year_rate);
  z_site ~ std_normal();
  z_year ~ std_normal();
  if (prior_only == 0) {
    vector[n_obs] cover;
    for (i in 1:n_obs) {
      cover[i] = fmin(
        plot_area_m2[i],
        canopy_area_m2[i] * (1 + tide_height_slope * tide_height_m[i])
      ) / plot_area_m2[i];
    }
    vector[n_obs] log_mu = log(biomass_floor
      + cover_slope * exp(site_effect[site] + year_effect[year]) .* cover);
    log_biomass ~ normal(log_mu, error_scaling * log_biomass_sd);
  }
}
