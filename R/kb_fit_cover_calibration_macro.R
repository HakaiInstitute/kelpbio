#' Fit a Macrocystis cover calibration model
#'
#' Fit a calibration of in situ survey biomass on plot cover for
#' *Macrocystis pyrifera* via Stan.
#'
#' @inherit kb_fit_cover_calibration_nereo details
#' @inheritSection params Model
#' @inheritSection params Sampling
#' @inheritParams kb_fit_weight_nereo
#' @inheritParams params
#' @param data A data frame of in situ survey biomass with plot cover, one row
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
#' biomass <- kb_predict_biomass_in_situ(
#'   fit_weight_sim_macro,
#'   data_size_census_sim_macro,
#'   data_survey_in_situ_sim_macro
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
