# The main kelpbio workflow, from input data to biomass totals, in three
# scenarios. Run block by block after devtools::install(). The fitting blocks
# run MCMC, so expect them to take a little time. For every argument and edge
# case, see scripts/demo-api-test.R.
#
# 1. Full workflow (Nereocystis): fit every model, calibrate drone cover, and
#    total the biomass over the mapped canopy.
# 2. A pre-fit weight model: no harvests of one's own, so the weight model comes
#    from elsewhere (here the bundled fit_weight_sim_nereo).
# 3. A census with no drone cover: every plant on the plots measured, so the
#    biomass of the surveyed area comes straight from the plants, with no size
#    model and no calibration.

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
# 2. A PRE-FIT WEIGHT MODEL
# =============================================================================
# Without harvests, a weight model fitted elsewhere stands in. Its sites and
# years are those of the data it was fitted to, so the surveyed site-years it
# lacks take a sampled effect: weight_support says so. The fits combined must
# have the same number of draws, so the size model is fitted with the
# pre-fit's chains and draws (3 chains of 500).

fit_weight_prefit <- fit_weight_sim_nereo
fit_weight_prefit
posterior::ndraws(fit_weight_prefit)

fit_size_matched <- kb_fit_size_nereo(
  data_size_sample_sim_nereo,
  chains = 3L,
  niters = 500L
)
posterior::ndraws(fit_size_matched)

biomass_prefit <- kb_predict_biomass_survey(
  fit_weight_prefit,
  fit_size_matched,
  data_survey_sim_nereo
)
count(biomass_prefit, weight_support)

# the rest of the workflow is as in scenario 1
fit_cover_prefit <- kb_fit_cover_calibration_nereo(
  biomass_prefit,
  chains = 3L,
  niters = 500L
)
kb_predict_biomass_canopy(
  fit_cover_prefit,
  data_canopy_sim_nereo,
  pool_by = "year"
)

# a weight model whose sites match none of the surveys: borrow one site's
# effects for every new site rather than sampling them
kb_predict_mean_weight(
  fit_weight_prefit,
  fit_size_matched,
  tibble::tibble(site = "my_site", year = "2021"),
  representative_site = "otter_cove"
)

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
