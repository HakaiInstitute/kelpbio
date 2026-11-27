#' Fit a Nereocystis cover calibration model
#'
#' Fit a calibration of in situ survey biomass on plot cover for
#' *Nereocystis luetkeana* via Stan.
#'
#' @details
#' `data` is the output of [kb_predict_biomass_in_situ()] with its defaults.
#' Surveys without plot cover are not fitted, and a message gives their number.
#' The model is described in
#' [Methods](https://hakaiinstitute.github.io/kelpbio/articles/methods.html#cover-calibration).
#'
#' The fit warns when a survey with canopy has a tide height above 2 m, and
#' when every survey with no plants has a plot cover at or below that of every
#' survey with plants, since `presence_cover_slope` is then informed only by
#' its prior. If canopy is already tide-corrected, set
#' `canopy_tide_height_m = 0`.
#'
#' @inheritSection params Model
#' @inheritSection params Sampling
#' @inheritParams kb_fit_weight_nereo
#' @inheritParams params
#' @param data A data frame of in situ survey biomass with plot cover, one row
#'   per survey (see [kb_check_data_cover_calibration_nereo()] for the columns).
#' @param priors A named list of prior objects (see
#'   [kb_priors_cover_calibration_nereo()]), or `NULL` to use the defaults.
#'   Entries not supplied keep their defaults.
#'
#' @returns A `kb_fit_cover_calibration_nereo` object (a `kb_fit`). Its `data`
#'   holds the fitted surveys, with `biomass_kg_m2` the mean of each survey's
#'   draws and `biomass_sd_kg_m2` their SD.
#' @family fit functions
#' @export
#'
#' @examples
#' # A pre-fit example model is included with the package:
#' tidy(fit_cover_calibration_sim_nereo)
#' @examplesIf interactive()
#' biomass <- kb_predict_biomass_in_situ(
#'   fit_weight_sim_nereo,
#'   fit_size_sim_nereo,
#'   data_survey_in_situ_sim_nereo
#' )
#' fit <- kb_fit_cover_calibration_nereo(biomass)
#' tidy(fit)
kb_fit_cover_calibration_nereo <- function(
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
    species = "nereocystis",
    check_data = kb_check_data_cover_calibration_nereo,
    defaults = kb_priors_cover_calibration_nereo(),
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
