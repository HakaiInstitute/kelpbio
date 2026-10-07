// Macrocystis plant density (site-year resolution): the number of plants on a
// transect follows a negative binomial, with the transect area as an offset.
//   plants ~ NegBinomial(area_m2 * exp(log_density), 1 / dispersion)
//   log_density = intercept + site_effect[site] + year_effect[year]
//                 + site_year_effect[site, year]
// exp(log_density) is the density (plants per m^2), so the expected count is
// area_m2 * exp(log_density). Random effects: site, year, and site:year, all on
// log_density. Priors are passed as data; the prior family is fixed at compile
// time. The mean is a local in the model block so it is not saved with the
// draws. The pointwise log-likelihood and posterior-predictive replicates are
// computed in R from the stored draws, so there are no generated quantities.
data {
  int<lower=0> n_obs;                     // 0 allowed: supports prior-only / empty fits
  int<lower=1> n_site;
  int<lower=1> n_year;
  array[n_obs] int<lower=1, upper=n_site> site;
  array[n_obs] int<lower=1, upper=n_year> year;
  array[n_obs] int<lower=0> plants;
  vector<lower=0>[n_obs] area_m2;         // area surveyed (m^2)

  // priors (hyperparameters passed as data)
  real prior_intercept_mean;
  real<lower=0> prior_intercept_sd;
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
  for (i in 1:n_obs) {
    sy_idx[i] = site[i] + (year[i] - 1) * n_site;
  }
}
parameters {
  real intercept;                         // log plants per m^2 at a typical site and year
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
    vector[n_obs] log_mu = log_area + intercept + site_effect[site] + year_effect[year]
      + site_year_on * to_vector(site_year_effect)[sy_idx];
    plants ~ neg_binomial_2_log(log_mu, 1 / dispersion);
  }
}
