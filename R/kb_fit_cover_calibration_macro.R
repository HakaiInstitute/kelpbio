#' Fit a Macrocystis cover calibration model
#'
#' Fit a calibration of in situ survey biomass on drone canopy cover for
#' *Macrocystis pyrifera* via Stan.
#'
#' @details
#' `data` is the output of [kb_predict_biomass_survey()] with its defaults: wet
#' biomass per m² of each in situ survey, with the survey's drone cover on its
#' row. Each survey with drone cover is one observation; surveys without it
#' are not fitted, and a message gives their number. The calibration takes each
#' survey's biomass per m² as that of its plot.
#'
#' A survey's mean wet biomass (kg/m²) is modelled with a Normal likelihood
#' censored below at zero, so a survey with no plants counted enters as the
#' probability of zero or less. Its mean is `mu = biomass_floor + cover_slope *
#' exp(site_effect + year_effect) * cover`: `cover_slope` is the wet biomass per
#' m² of canopy at a typical site and year, and `biomass_floor`, common to all
#' sites and years, the wet biomass of a plot with no delineated canopy. Its SD
#' is `sqrt(sd_residual^2 + (cv_residual * mu)^2 + biomass_sd^2)`, where
#' `biomass_sd` is the SD of the survey's biomass draws, from plant weight.
#'
#' `cover` is the canopy area divided by one minus `tide_height_slope` times the
#' tide height, since less of the canopy is visible at the surface at higher
#' tides, over the plot area and capped at 1. The default prior on
#' `tide_height_slope` is informative and largely sets the tide correction,
#' because calibration data rarely separate tide height from other
#' differences between surveys.
#'
#' @inheritSection params Sampling
#' @inheritParams kb_fit_weight_nereo
#' @inheritParams params
#' @param data A data frame of in situ survey biomass with drone cover, one row
#'   per survey (see [kb_check_data_cover_calibration_macro()] for the columns).
#' @param priors A named list of prior objects (see
#'   [kb_priors_cover_calibration_macro()]), or `NULL` to use the defaults.
#'   Entries not supplied keep their defaults.
#'
#' @returns A `kb_fit_cover_calibration_macro` object (a `kb_fit`). Its `data`
#'   holds the fitted surveys, with `biomass_kg_m2` the mean of each survey's
#'   draws and `biomass_sd_kg_m2` their SD.
#' @family fit functions
#' @export
#'
#' @examples
#' # A pre-fit example model is included with the package:
#' tidy(fit_cover_calibration_sim_macro)
#' @examplesIf interactive()
#' biomass <- kb_predict_biomass_survey(
#'   fit_weight_sim_macro,
#'   data_plants_sim_macro,
#'   data_survey_sim_macro
#' )
#' fit <- kb_fit_cover_calibration_macro(biomass)
#' tidy(fit)
kb_fit_cover_calibration_macro <- function(
  data,
  priors = NULL,
  ...,
  prior_only = FALSE,
  chains = 4L,
  niters = 1000L,
  nthin = 1L,
  cores = NULL,
  seed = NULL,
  progress = c("bar", "verbose", "none"),
  progress_dir = NULL
) {
  fit_cover_calibration_model(
    data,
    priors,
    species = "macrocystis",
    check_data = kb_check_data_cover_calibration_macro,
    defaults = kb_priors_cover_calibration_macro(),
    ...,
    prior_only = prior_only,
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir
  )
}
