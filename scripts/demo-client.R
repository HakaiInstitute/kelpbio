# kelpbio workflow demo; run block by block after devtools::install().

library(kelpbio)
library(kelpbiodata)
library(dplyr)
library(ggplot2)

# unobserved sites and years take sampled effects
set.seed(42)

# =============================================================================
# 1. FULL WORKFLOW (NEREOCYSTIS)
# =============================================================================

# --- inputs -------------------------------------------------------------------
# harvested plants
str(data_weight_sim_nereo)
# measured plants
str(data_size_sample_sim_nereo)
# in situ surveys
str(data_survey_sim_nereo)
# drone-mapped canopy
str(data_canopy_sim_nereo)
# tissue samples
str(data_wetdry_sim_nereo)
str(data_carbon_sim_nereo)

# data checks (also run inside the fits)
kb_check_data_weight_nereo(data_weight_sim_nereo)
kb_check_data_size_sample_nereo(data_size_sample_sim_nereo)
kb_check_data_survey(data_survey_sim_nereo)

# --- fit the sub-models ---------------------------------------------------------
fit_weight <- kb_fit_weight_nereo(data_weight_sim_nereo)
fit_size <- kb_fit_size_nereo(data_size_sample_sim_nereo)
fit_wetdry <- kb_fit_wetdry_nereo(data_wetdry_sim_nereo)
fit_carbon <- kb_fit_carbon_nereo(data_carbon_sim_nereo)

# convergence and estimates
fit_weight
glance(fit_weight)
tidy(fit_weight)
kb_model_describe(fit_weight)

# weight and size by site
kb_predict_weight(fit_weight, kb_new_data(fit_weight, by = "site")) |>
  kb_plot_predictions()
kb_predict_size(fit_size, kb_new_data(fit_size, by = "site")) |>
  kb_plot_predictions() +
  coord_flip()

# posterior predictive check
pp_check(fit_weight)

# --- mean plant weight ------------------------------------------------------------
mean_weight <- kb_predict_mean_weight(fit_weight, fit_size)
mean_weight
kb_plot_predictions(mean_weight)

# --- survey biomass ---------------------------------------------------------------
# biomass per m2 of each survey
biomass <- kb_predict_biomass_survey(
  fit_weight,
  fit_size,
  data_survey_sim_nereo
)
biomass
# pooled by site-year
x <- kb_predict_biomass_survey(
  fit_weight,
  fit_size,
  data_survey_sim_nereo,
  pool_by = c("site", "year")
)

# --- calibrate drone cover --------------------------------------------------------
# fitted to surveys with drone cover
fit_cover <- kb_fit_cover_calibration_nereo(biomass)
fit_cover
kb_converged(fit_cover)
tidy(fit_cover)
kb_model_describe(fit_cover)
pp_check(fit_cover)

# biomass against cover by site
kb_predict_cover_calibration(fit_cover, kb_new_data(fit_cover, by = "site")) |>
  kb_plot_predictions()

# observed and fitted biomass
augment(fit_cover) |>
  ggplot(aes(canopy_area_m2 / plot_area_m2, biomass_kg_m2)) +
  geom_point() +
  geom_point(aes(y = fitted), shape = 1, colour = "red") +
  labs(x = "Canopy cover (uncorrected)", y = "Wet biomass (kg/m²)")

# --- biomass over the mapped canopy -----------------------------------------------
totals <- kb_predict_biomass_canopy(fit_cover, data_canopy_sim_nereo)
totals
kb_plot_predictions(totals)

# pooled by year and by region-year
kb_predict_biomass_canopy(fit_cover, data_canopy_sim_nereo, pool_by = "year") |>
  kb_plot_predictions()
kb_predict_biomass_canopy(
  fit_cover,
  data_canopy_sim_nereo,
  pool_by = c("region", "year")
)

# carbon stock by year
kb_predict_biomass_canopy(
  fit_cover,
  data_canopy_sim_nereo,
  fit_wetdry,
  fit_carbon,
  measure = "carbon",
  pool_by = "year"
) |>
  kb_plot_predictions()

# =============================================================================
# 2. REFERENCE FITS
# =============================================================================
# coastwide weight fit and Hakai wet/dry and carbon fits stand in for own data

fit_weight_coastwide_nereo
count(fit_weight_coastwide_nereo$data, study, region)
kb_predict_weight(
  fit_weight_coastwide_nereo,
  kb_new_data(fit_weight_coastwide_nereo)
) |>
  kb_plot_predictions()

# new sites take sampled weight effects (see weight_support)
biomass_ref <- kb_predict_biomass_survey(
  fit_weight_coastwide_nereo,
  fit_size,
  data_survey_sim_nereo
)
count(biomass_ref, weight_support)
biomass_ref

# borrow the weight effects of chosen reference sites
distinct(kb_new_data(fit_weight_coastwide_nereo, by = "site"), site)
central_coast <- c("pontier:North", "pontier:Second", "pontier:Triquetta")
biomass_rep <- kb_predict_biomass_survey(
  fit_weight_coastwide_nereo,
  fit_size,
  data_survey_sim_nereo,
  representative_site = list(weight = central_coast)
)
biomass_rep

# carbon by year from reference fits
fit_cover_rep <- kb_fit_cover_calibration_nereo(biomass_rep)
kb_predict_biomass_canopy(
  fit_cover_rep,
  data_canopy_sim_nereo,
  fit_wetdry_hakai_nereo,
  fit_carbon_hakai_nereo,
  measure = "carbon",
  pool_by = "year"
) |>
  kb_plot_predictions()

# =============================================================================
# 3. A CENSUS WITH NO DRONE COVER
# =============================================================================
# every plant measured, so no size model or calibration; census simulated here

survey_census <- data_survey_sim_nereo |>
  select(survey_id, site, year, survey_area_m2, plants)

size_census <- survey_census |>
  rowwise() |>
  reframe(
    survey_id,
    diameter_mm = {
      measured <- data_size_sample_sim_nereo$diameter_mm[
        data_size_sample_sim_nereo$site == site &
          data_size_sample_sim_nereo$year == year
      ]
      if (!length(measured)) {
        measured <- data_size_sample_sim_nereo$diameter_mm
      }
      sample(measured, plants, replace = TRUE)
    }
  )
# counts come from the census rows
survey_census <- select(survey_census, -plants)

str(survey_census)
str(size_census)
kb_check_data_survey(survey_census, size_census)

# biomass per survey (kg) and per m2
census_kg <- kb_predict_biomass_survey(
  fit_weight,
  size_census,
  survey_census,
  per_area = FALSE
)
census_kg
kb_predict_biomass_survey(fit_weight, size_census, survey_census)

# total by site-year and dry by site
kb_predict_biomass_survey(
  fit_weight,
  size_census,
  survey_census,
  per_area = FALSE,
  pool_by = c("site", "year")
) |>
  kb_plot_predictions()
kb_predict_biomass_survey(
  fit_weight,
  size_census,
  survey_census,
  fit_wetdry,
  measure = "dry",
  per_area = FALSE,
  pool_by = "site"
)

# =============================================================================
# 4. INTEROPERABILITY AND ADVANCED USE
# =============================================================================
# see vignette("advanced")

# broom
tidy(fit_weight)
glance(fit_weight)

# posterior
draws <- as_draws(fit_weight)
draws
posterior::summarise_draws(draws)

# trace and rank plots of chosen terms, straight from the draws
draws_array <- posterior::as_draws_array(fit_weight)
bayesplot::mcmc_trace(draws_array, pars = c("intercept", "diameter_power"))
# chains that have mixed have flat, overlapping rank histograms
bayesplot::mcmc_rank_overlay(
  draws_array,
  pars = c("intercept", "diameter_power")
)

# bayesplot and loo
pp_check(fit_size)
loo(fit_weight)

# ggplot2
autoplot(mean_weight) +
  labs(title = "Mean plant weight by site-year")

# change in total biomass, first to last year, draw by draw
by_year <- kb_predict_biomass_canopy(
  fit_cover,
  data_canopy_sim_nereo,
  pool_by = "year"
)
change <- by_year$biomass_kg[nrow(by_year)] - by_year$biomass_kg[1]
change
posterior::quantile2(change, probs = c(0.025, 0.5, 0.975))
mean(change > 0)
