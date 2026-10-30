// Cover calibration, both species: the wet biomass of an in situ survey
// (kg/m^2) is a floor plus a term proportional to its plot's tide-corrected
// canopy cover.
//   biomass ~ Gamma(shape, shape / mu), shape = 1 / (cv_residual^2 + weight_cv^2)
//   mu = biomass_floor + cover_slope * exp(site_effect[site] + year_effect[year]) * cover
//   seen = 1 - tide_height_slope * canopy_tide_height_m
//   cover = 0                                            if canopy_area_m2 = 0
//         = min(plot_area_m2, canopy_area_m2 / seen) / plot_area_m2   if seen > 0
//         = 1                                            otherwise
// Past one over the slope (seen <= 0) the division has no finite value, so a
// plot with canopy takes the limit of the capped value, full cover.
// tide_height_slope is the share of the zero-tide canopy lost per metre of
// tide. weight_cv is each survey's CV of biomass from plant weight (the count
// is a census of the surveyed area), so its pull on the line depends only on
// how precisely its plants were weighed. The group effects scale the canopy
// term only.
//
// With presence_on (data holding a survey with nothing counted), a survey
// holds plants with probability
//   logit(p) = presence_intercept + presence_cover_slope * 100 * cover
// and its biomass is Gamma only where it does: an empty survey contributes
// log(1 - p) alone. Without presence_on the presence parameters take their
// priors and do not enter the likelihood.
data {
  int<lower=0> n_obs;
  int<lower=1> n_site;
  int<lower=1> n_year;
  array[n_obs] int<lower=1, upper=n_site> site;
  array[n_obs] int<lower=1, upper=n_year> year;
  vector<lower=0>[n_obs] canopy_area_m2;
  vector<lower=0>[n_obs] plot_area_m2;
  vector[n_obs] canopy_tide_height_m;
  vector<lower=0>[n_obs] biomass;          // mean survey wet biomass (kg/m^2)
  vector<lower=0>[n_obs] weight_cv;
  array[n_obs] int<lower=0, upper=1> zero;

  real prior_cover_slope_meanlog;
  real<lower=0> prior_cover_slope_sdlog;
  real prior_biomass_floor_mean;
  real<lower=0> prior_biomass_floor_sd;
  real prior_tide_height_slope_mean;
  real<lower=0> prior_tide_height_slope_sd;
  real<lower=0> prior_cv_residual_rate;
  real prior_presence_intercept_mean;
  real<lower=0> prior_presence_intercept_sd;
  real prior_presence_cover_slope_mean;
  real<lower=0> prior_presence_cover_slope_sd;
  real<lower=0> prior_sd_site_rate;
  real<lower=0> prior_sd_year_rate;

  int<lower=0, upper=1> presence_on;
  int<lower=0, upper=1> prior_only;
}
parameters {
  real<lower=0> cover_slope;              // kg per m^2 of canopy, typical site and year
  real<lower=0> biomass_floor;            // kg/m^2 at zero cover
  real<lower=0, upper=0.5> tide_height_slope;
  real<lower=0> cv_residual;              // CV of survey biomass about mu
  real presence_intercept;                // logit p at zero cover
  real presence_cover_slope;              // per percentage point of cover
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
  cv_residual ~ exponential(prior_cv_residual_rate);
  presence_intercept ~ normal(prior_presence_intercept_mean, prior_presence_intercept_sd);
  presence_cover_slope ~ normal(prior_presence_cover_slope_mean, prior_presence_cover_slope_sd);
  sd_site ~ exponential(prior_sd_site_rate);
  sd_year ~ exponential(prior_sd_year_rate);
  z_site ~ std_normal();
  z_year ~ std_normal();
  if (prior_only == 0) {
    for (i in 1:n_obs) {
      real seen = 1 - tide_height_slope * canopy_tide_height_m[i];
      real cover = 0;
      if (canopy_area_m2[i] > 0) {
        cover = seen > 0
          ? fmin(plot_area_m2[i], canopy_area_m2[i] / seen) / plot_area_m2[i]
          : 1;
      }
      real logit_p = presence_intercept + presence_cover_slope * 100 * cover;
      if (zero[i] == 1) {
        target += log1m_inv_logit(logit_p);
      } else {
        real mu = biomass_floor
          + cover_slope * exp(site_effect[site[i]] + year_effect[year[i]]) * cover;
        real shape = 1 / (square(cv_residual) + square(weight_cv[i]));
        if (presence_on == 1) {
          target += log_inv_logit(logit_p);
        }
        target += gamma_lpdf(biomass[i] | shape, shape / mu);
      }
    }
  }
}
