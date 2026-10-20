# The main kelpbio workflow, from input data to biomass totals, in three
# scenarios, then a short tour of how the results work with other packages.
# Run block by block after devtools::install(). The fitting blocks run MCMC, so
# expect them to take a little time. For every argument and edge case, see
# scripts/demo-api-test.R.
#
# 1. Full workflow (Nereocystis): fit every model, calibrate drone cover, and
#    total the biomass over the mapped canopy.
# 2. Reference fits: no harvests or tissue samples of one's own, so the weight,
#    wet/dry, and carbon models come from the bundled reference fits.
# 3. A census with no drone cover: every plant on the plots measured, so the
#    biomass of the surveyed area comes straight from the plants, with no size
#    model and no calibration.
# 4. Interoperability and advanced use: tidy summaries, posterior draws,
#    model checks, and custom summaries of the draws.

library(kelpbio)
library(dplyr)
library(ggplot2)

# Sites and years without data take a sampled effect, so set a seed.
set.seed(42)

# =============================================================================
# 1. FULL WORKFLOW (NEREOCYSTIS)
# =============================================================================

# --- inputs -------------------------------------------------------------------
# A plant is one individual (sporophyte), identified by its holdfast.

# harvested plants: sub-bulb diameter and wet weight
str(data_weight_sim_nereo)
# measured plants: the size distribution of each site-year
str(data_size_sample_sim_nereo)
# in situ surveys: one row per survey (survey_id, site, year), the surveyed
# area, the plants tallied, and, where a drone flew, the plot polygon,
# canopy, and tide height
str(data_survey_sim_nereo)
# drone-mapped canopy of each site-year, for totals
str(data_canopy_sim_nereo)
# tissue samples for dry and carbon biomass
str(data_wetdry_sim_nereo)
str(data_carbon_sim_nereo)

# the data checks run inside the fits too; calling them first shows problems early
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

# the weight curve by site, and the size of plants by site
kb_predict_weight(fit_weight, kb_new_data(fit_weight, by = "site")) |>
  kb_plot_predictions()
kb_predict_size(fit_size, kb_new_data(fit_size, by = "site")) |>
  kb_plot_predictions() +
  coord_flip()

# posterior predictive check: replicate weights against the observed
pp_check(fit_weight)

# --- mean plant weight ------------------------------------------------------------
# the weight curve averaged over each site-year's size distribution
mean_weight <- kb_predict_mean_weight(fit_weight, fit_size)
mean_weight
kb_plot_predictions(mean_weight)

# --- survey biomass ---------------------------------------------------------------
# each survey's plants times its site-year's mean plant weight, per m2 of the
# surveyed area; the draws travel in the biomass_kg_m2 column
biomass <- kb_predict_biomass_survey(
  fit_weight,
  fit_size,
  data_survey_sim_nereo
)
biomass
# pooled all sites biomass per year
x <- kb_predict_biomass_survey(
  fit_weight,
  fit_size,
  data_survey_sim_nereo,
  pool_by = c("site", "year")
)

# --- calibrate drone cover --------------------------------------------------------
# the surveys with drone cover are the observations; the others are left out
fit_cover <- kb_fit_cover_calibration_nereo(biomass)
fit_cover
kb_converged(fit_cover)
tidy(fit_cover)
kb_model_describe(fit_cover)
pp_check(fit_cover)

# biomass per m2 of plot against tide-corrected cover, by site
kb_predict_cover_calibration(fit_cover, kb_new_data(fit_cover, by = "site")) |>
  kb_plot_predictions()

# the calibration with the survey biomass it was fitted to
augment(fit_cover) |>
  ggplot(aes(canopy_area_m2 / plot_area_m2, biomass_kg_m2)) +
  geom_point() +
  geom_point(aes(y = fitted), shape = 1, colour = "red") +
  labs(x = "Canopy cover (uncorrected)", y = "Wet biomass (kg/m²)")

# --- biomass over the mapped canopy -----------------------------------------------
totals <- kb_predict_biomass_canopy(fit_cover, data_canopy_sim_nereo)
totals
kb_plot_predictions(totals)

# summed by year and by region, draw by draw
kb_predict_biomass_canopy(fit_cover, data_canopy_sim_nereo, pool_by = "year") |>
  kb_plot_predictions()
kb_predict_biomass_canopy(
  fit_cover,
  data_canopy_sim_nereo,
  pool_by = c("region", "year")
)

# carbon stock (kg C) by year
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
# Without harvests, a reference weight fit stands in: here the coastwide
# Nereocystis fit, compiled from harvests from Alaska to California. Without
# tissue samples, the Hakai Institute wet/dry and carbon fits stand in too.
# Reference fits have 4000 draws, as a fit with the default sampler settings
# does, so they combine with the size fit from scenario 1.

fit_weight_coastwide_nereo
count(fit_weight_coastwide_nereo$data, study, region)
kb_predict_weight(
  fit_weight_coastwide_nereo,
  kb_new_data(fit_weight_coastwide_nereo)
) |>
  kb_plot_predictions()

# none of the surveyed sites is in the reference data, so each site takes a
# sampled weight effect from the variation among the coastwide sites:
# weight_support says so, and the intervals are wide
biomass_ref <- kb_predict_biomass_survey(
  fit_weight_coastwide_nereo,
  fit_size,
  data_survey_sim_nereo
)
count(biomass_ref, weight_support)
biomass_ref

# Where the surveyed sites are judged to resemble particular reference sites,
# representative_site gives them those sites' weight effects (averaged when
# several are named). The size fit keeps its own site estimates.
distinct(kb_new_data(fit_weight_coastwide_nereo, by = "site"), site) # sites to choose from
central_coast <- c("pontier:North", "pontier:Second", "pontier:Triquetta")
biomass_rep <- kb_predict_biomass_survey(
  fit_weight_coastwide_nereo,
  fit_size,
  data_survey_sim_nereo,
  representative_site = list(weight = central_coast)
)
biomass_rep

# the rest of the workflow is as in scenario 1, with dry and carbon biomass
# from the Hakai Institute reference fits
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
# Every plant on each plot is counted and its sub-bulb diameter measured, and
# no drone flew. The size census replaces the size model, and the biomass of the
# surveyed area is the sum of its plants' expected weights: no calibration is
# needed. Here a census is simulated by giving each tallied plant a diameter
# drawn from its site-year's measured sizes.

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
# the counts now come from the size census rows, so the survey loses its tally
survey_census <- select(survey_census, -plants)

str(survey_census)
str(size_census)
kb_check_data_survey(survey_census, size_census)

# biomass in each surveyed area (kg), and per m2
census_kg <- kb_predict_biomass_survey(
  fit_weight,
  size_census,
  survey_census,
  per_area = FALSE
)
census_kg
kb_predict_biomass_survey(fit_weight, size_census, survey_census)

# total biomass of the plots by site and year, and dry biomass by year
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
# Fits and predictions work with the broom, posterior, bayesplot, loo, and
# ggplot2 packages. See vignette("advanced") for more.

# tidy summaries of the estimates and the fit (broom)
tidy(fit_weight)
glance(fit_weight)

# the posterior draws of the estimates (posterior)
draws <- kb_samples(fit_weight)
draws
posterior::summarise_draws(draws)

# model checks: replicate data against observed (bayesplot), and the
# out-of-sample predictive accuracy of a model (loo)
pp_check(fit_size)
loo(fit_weight)

# predictions plot with ggplot2's autoplot() and take ggplot2 layers
autoplot(mean_weight) +
  labs(title = "Mean plant weight by site-year")

# Every prediction keeps its draws in the response column, so any summary
# is computed draw by draw: here the change in total biomass between the
# first and last year, and the probability that biomass increased.
by_year <- kb_predict_biomass_canopy(
  fit_cover,
  data_canopy_sim_nereo,
  pool_by = "year"
)
change <- by_year$biomass_kg[nrow(by_year)] - by_year$biomass_kg[1]
change
posterior::quantile2(change, probs = c(0.025, 0.5, 0.975))
mean(change > 0)
