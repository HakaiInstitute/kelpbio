// Full allometric weight model (site-year resolution).
// log(weight_kg) ~ normal(log(mu), sd_residual) where
//   mu         = weight_floor + alpha * x^diameter_power
//   log(alpha) = intercept + density_slope * density + year_effect[year]
//                + site_effect[site] + site_year_effect[site, year]
//   x          = diameter_mm / diameter_ref
//
// The mean function is Packard's (2023) three-parameter power function,
// W = a + b * D^c, with diameter expressed relative to a reference so that alpha
// is the weight above the floor at diameter_ref. weight_floor is the weight (kg)
// as diameter approaches zero, and diameter_power the allometric scaling
// exponent; neither depends on diameter_ref. The implied log-log slope,
// diameter_power * (mu - weight_floor) / mu, is increasing and bounded in
// (0, diameter_power), so expected weight is monotone in diameter.
//
// floor_on = 0 drops the floor (the "power" form), giving the power law
// mu = alpha * x^diameter_power, linear on log-log axes.
//
// The random effects act on alpha, not on the whole expectation: they scale the
// size-dependent part of the weight and leave the floor common, since the floor
// reflects which small plants are harvested rather than site condition.
//
// Gaussian on log weight, not Student-t: a Student-t has no finite exponential
// moment, so E[weight | diameter] would not exist and weight could not be
// averaged over the size distribution for biomass.
//
// diameter_ref is passed as data (the geometric mean of the observed diameter),
// so alpha is the weight at a typical plant and intercept and diameter_power are
// close to uncorrelated in the posterior.
//
// density is the site-year stipe density, standardised in R (0 = the mean over
// the fitted plants, also used where a site-year has no recorded density).
//
// Random effects: year, site, and site:year, all on log(alpha).
// Priors are passed as data; the prior family is fixed at compile time.
// The mean is computed with vectorised indexing (no per-observation loop) for a
// smaller autodiff graph, as a local in the model block so it is not saved with
// the draws. The pointwise log-likelihood and posterior-predictive replicates are
// computed in R from the stored draws, so there are no generated quantities.
data {
  int<lower=0> n_obs;                     // 0 allowed: supports prior-only / empty fits
  int<lower=1> n_site;
  int<lower=1> n_year;
  array[n_obs] int<lower=1, upper=n_site> site;
  array[n_obs] int<lower=1, upper=n_year> year;
  vector<lower=0>[n_obs] diameter_mm;
  vector<lower=0>[n_obs] weight_kg;
  real<lower=0> diameter_ref;             // diameter reference for x (mm)
  vector[n_obs] density;                  // standardised site-year stipe density

  // priors (hyperparameters passed as data)
  real prior_intercept_mean;
  real<lower=0> prior_intercept_sd;
  real prior_diameter_power_mean;         // truncated at 0 by the declaration
  real<lower=0> prior_diameter_power_sd;
  real prior_weight_floor_mean;           // truncated at 0 by the declaration
  real<lower=0> prior_weight_floor_sd;
  real prior_density_slope_mean;
  real<lower=0> prior_density_slope_sd;
  real<lower=0> prior_sd_site_rate;
  real<lower=0> prior_sd_year_rate;
  real<lower=0> prior_sd_site_year_rate;
  real<lower=0> prior_sd_residual_rate;

  int<lower=0, upper=1> prior_only;       // 1 = skip likelihood, sample from priors
  int<lower=0, upper=1> site_year_on;     // 0 = drop the site:year term (set to 0)
  int<lower=0, upper=1> density_on;       // 0 = drop the density term
  int<lower=0, upper=1> floor_on;         // 0 = drop the floor (power-law form)
}
transformed data {
  vector[n_obs] log_x = log(diameter_mm) - log(diameter_ref);
  vector[n_obs] log_weight = log(weight_kg);
  // column-major linear index into to_vector(site_year_effect): (site, year) ->
  // site + (year - 1) * n_site. Lets the site:year term be one vectorised gather.
  array[n_obs] int sy_idx;
  for (i in 1:n_obs) {
    sy_idx[i] = site[i] + (year[i] - 1) * n_site;
  }
}
parameters {
  real intercept;                         // log(alpha) at a typical site and year
  real<lower=0> diameter_power;           // allometric scaling exponent
  real<lower=0> weight_floor;             // weight (kg) as diameter approaches zero
  real density_slope;                     // effect of standardised density on log(alpha)
  real<lower=0> sd_site;                  // site SD
  real<lower=0> sd_year;                  // year SD
  real<lower=0> sd_site_year;             // site:year SD
  real<lower=0> sd_residual;              // residual SD of log weight
  vector[n_site] z_site;                  // non-centred site effects
  vector[n_year] z_year;                  // non-centred year effects
  matrix[n_site, n_year] z_site_year;     // non-centred site:year effects
}
transformed parameters {
  vector[n_site] site_effect = z_site * sd_site;
  vector[n_year] year_effect = z_year * sd_year;
  matrix[n_site, n_year] site_year_effect = z_site_year * sd_site_year;
}
model {
  intercept ~ normal(prior_intercept_mean, prior_intercept_sd);
  // <lower=0> plus fixed hyperparameters makes these truncated normals whose
  // normalising constants do not depend on any parameter, so no T[0,] is needed.
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
    // Vectorised mean: gather random effects by observation, combine elementwise.
    // A local, not a transformed parameter: rstan saves transformed parameters,
    // and n_obs columns per draw is the largest thing in a stored fit. Predictions
    // and the pointwise log-likelihood are computed in R from the stored draws.
    vector[n_obs] log_alpha = intercept + density_on * density_slope * density
      + year_effect[year] + site_effect[site]
      + site_year_on * to_vector(site_year_effect)[sy_idx];
    vector[n_obs] log_mu = log(floor_on * weight_floor
      + exp(log_alpha + diameter_power * log_x));
    log_weight ~ normal(log_mu, sd_residual);
  }
}
