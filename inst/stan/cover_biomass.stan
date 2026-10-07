// Cover-biomass calibration, shared by both species: the in situ wet biomass of a
// drone-surveyed plot is a biomass floor plus a term proportional to the
// tide-corrected canopy cover of the plot.
//   log(biomass) ~ normal(log(mu), error_scaling * log_biomass_sd)
//   mu = biomass_floor
//        + cover_slope * exp(site_effect[site] + year_effect[year]) * cover
//   cover = min(plot_area_m2,
//               canopy_area_m2 * (1 + tide_height_slope * tide_height_m))
//           / plot_area_m2
// biomass is the in situ estimate (kg/m^2) and log_biomass_sd the log-scale SD
// of that estimate, so surveys are weighted by their relative precision and
// error_scaling calibrates the supplied SDs. cover_slope is the wet biomass per
// m^2 of tide-corrected canopy at a typical site and year, and biomass_floor the
// wet biomass at zero cover, common to all sites and years; the site and year
// effects scale the canopy term only. tide_height_slope is the fractional
// increase in canopy area per metre of tide height, and the cap keeps cover at
// or below 1. Priors are passed as data;
// the prior family is fixed at compile time. The mean is a local in the model
// block so it is not saved with the draws. The pointwise log-likelihood and
// posterior-predictive replicates are computed in R from the stored draws, so
// there are no generated quantities.
data {
  int<lower=0> n_obs;                     // 0 allowed: supports prior-only / empty fits
  int<lower=1> n_site;
  int<lower=1> n_year;
  array[n_obs] int<lower=1, upper=n_site> site;
  array[n_obs] int<lower=1, upper=n_year> year;
  vector<lower=0>[n_obs] canopy_area_m2;  // canopy area in the plot (m^2)
  vector<lower=0>[n_obs] plot_area_m2;    // plot area (m^2)
  vector[n_obs] tide_height_m;            // tide height at the survey (m)
  vector[n_obs] log_biomass;              // log in situ wet biomass (kg/m^2)
  vector<lower=0>[n_obs] log_biomass_sd;  // log-scale SD of the in situ estimate

  // priors (hyperparameters passed as data)
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

  int<lower=0, upper=1> prior_only;       // 1 = skip likelihood, sample from priors
}
parameters {
  real<lower=0> cover_slope;              // kg per m^2 of canopy, typical site and year
  real<lower=0> biomass_floor;            // kg/m^2 at zero cover
  real<lower=0> tide_height_slope;        // fractional canopy increase per m of tide
  real<lower=0> error_scaling;            // multiplier on log_biomass_sd
  real<lower=0> sd_site;                  // site SD
  real<lower=0> sd_year;                  // year SD
  vector[n_site] z_site;                  // non-centered site effects
  vector[n_year] z_year;                  // non-centered year effects
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
