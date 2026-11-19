#' Fit a Nereocystis cover calibration model
#'
#' Fit a calibration of in situ survey biomass on plot cover for
#' *Nereocystis luetkeana* via Stan.
#'
#' @details
#' `data` is the output of [kb_predict_biomass_in_situ()] with its defaults: wet
#' biomass per m² of each in situ survey, with the survey's plot cover columns
#' on its row. Each survey with plot cover is one observation; surveys without
#' it are not fitted, and a message gives their number. The calibration takes
#' each survey's biomass per m² as that of its plot.
#'
#' When `data` holds a survey with no plants counted, the model adds a
#' presence component, i.e., the probability that plants are present. The fit warns when
#' every survey with no plants has a plot cover, before tide correction, at or
#' below that of every survey with plants, since `presence_cover_slope` is then difficult to estimate from data and
#' follows its prior.
#'
#' Canopy is corrected for tide (Timmer et al. 2024), and a survey whose
#' tide-corrected canopy exceeds its plot is capped at the plot area. At a tide height of
#' 1 / `tide_height_slope` or more (the tide limit), the correction has no
#' finite value and the survey is fully covered; the fit warns when a survey is
#' past the tide limit with more than 5% prior probability. The limit is at
#' least 2 m, so imagery at a tide of 2 m or below, as published practice
#' recommends, never reaches it. The default prior on `tide_height_slope`
#' largely sets the correction. If canopy is already tide-corrected,
#' set `canopy_tide_height_m = 0`.
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
#' @references Timmer, B., Reshitnyk, L. Y., Hessing-Lewis, M., Juanes, F.,
#'   Gendall, L., and Costa, M. (2024). Capturing accurate kelp canopy extent:
#'   integrating tides, currents, and species-level morphology in kelp remote
#'   sensing. *Frontiers in Environmental Science*, 12, 1338483.
#'   \doi{10.3389/fenvs.2024.1338483}
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
