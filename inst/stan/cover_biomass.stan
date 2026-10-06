// Cover-biomass calibration, shared by both species: the in situ wet biomass of a
// drone-surveyed plot is a biomass floor plus a term proportional to the
// tide-corrected canopy cover of the plot.
//   log(biomass) ~ normal(log(mu), bScaling * log_biomass_sd)
//   mu = bFloor + bCanopy * exp(bSite[site] + bYear[year]) * cover
//   cover = min(plot, canopy * (1 + bTide * tide)) / plot
// biomass is the in situ estimate (kg/m^2) and log_biomass_sd the log-scale SD of
// that estimate, so surveys are weighted by their relative precision and
// bScaling calibrates the supplied SDs. bCanopy is the wet biomass per m^2 of
// tide-corrected canopy at a typical site and year, and bFloor the wet biomass at
// zero cover, common to all sites and years; the site and year effects scale the
// canopy term only. bTide is the fractional increase in canopy area per metre of
// tide height, and the cap keeps cover at or below 1. Priors are passed as data;
// the prior family is fixed at compile time. The mean is a local in the model
// block so it is not saved with the draws. The pointwise log-likelihood and
// posterior-predictive replicates are computed in R from the stored draws, so
// there are no generated quantities.
data {
  int<lower=0> nObs;                      // 0 allowed: supports prior-only / empty fits
  int<lower=1> nSite;
  int<lower=1> nYear;
  array[nObs] int<lower=1, upper=nSite> site;
  array[nObs] int<lower=1, upper=nYear> year;
  vector<lower=0>[nObs] canopy;           // canopy area in the plot (m^2)
  vector<lower=0>[nObs] plot;             // plot area (m^2)
  vector[nObs] tide;                      // tide height at the survey (m)
  vector[nObs] log_biomass;               // log in situ wet biomass (kg/m^2)
  vector<lower=0>[nObs] log_biomass_sd;   // log-scale SD of the in situ estimate

  // priors (hyperparameters passed as data)
  real prior_canopy_mu;
  real<lower=0> prior_canopy_sd;
  real prior_floor_mu;
  real<lower=0> prior_floor_sd;
  real prior_tide_mu;
  real<lower=0> prior_tide_sd;
  real prior_scaling_mu;
  real<lower=0> prior_scaling_sd;
  real<lower=0> prior_sd_site_rate;
  real<lower=0> prior_sd_year_rate;

  int<lower=0, upper=1> prior_only;       // 1 = skip likelihood, sample from priors
}
parameters {
  real<lower=0> bCanopy;                  // kg per m^2 of canopy, typical site and year
  real<lower=0> bFloor;                   // kg/m^2 at zero cover
  real<lower=0> bTide;                    // fractional canopy increase per m of tide
  real<lower=0> bScaling;                 // multiplier on log_biomass_sd
  real<lower=0> sSite;                    // site SD
  real<lower=0> sYear;                    // year SD
  vector[nSite] z_bSite;                  // non-centered site effects
  vector[nYear] z_bYear;                  // non-centered year effects
}
transformed parameters {
  vector[nSite] bSite = z_bSite * sSite;
  vector[nYear] bYear = z_bYear * sYear;
}
model {
  bCanopy ~ lognormal(prior_canopy_mu, prior_canopy_sd);
  bFloor ~ normal(prior_floor_mu, prior_floor_sd);
  bTide ~ normal(prior_tide_mu, prior_tide_sd);
  bScaling ~ normal(prior_scaling_mu, prior_scaling_sd);
  sSite ~ exponential(prior_sd_site_rate);
  sYear ~ exponential(prior_sd_year_rate);
  z_bSite ~ std_normal();
  z_bYear ~ std_normal();
  if (prior_only == 0) {
    vector[nObs] cover;
    for (i in 1:nObs) {
      cover[i] = fmin(plot[i], canopy[i] * (1 + bTide * tide[i])) / plot[i];
    }
    vector[nObs] log_mu = log(bFloor + bCanopy * exp(bSite[site] + bYear[year]) .* cover);
    log_biomass ~ normal(log_mu, bScaling * log_biomass_sd);
  }
}
