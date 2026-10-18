#' Fit a Nereocystis cover biomass model
#'
#' Fit a cover-biomass calibration for *Nereocystis luetkeana* via Stan.
#'
#' @details
#' Each drone survey in `data` is paired with the in situ wet biomass of its
#' site-year in `biomass`, typically the output of
#' [kb_predict_plot_biomass()] with `measure = "wet"`. Surveys whose
#' site-year has no biomass are not fitted, and a message notifies which
#' those are.
#'
#' The log of the in situ wet biomass estimate (kg/m²) is modelled with a
#' Normal likelihood with mean `log(mu)` and standard deviation
#' `error_scaling` times the log-scale SD implied by the estimate's `lower`
#' and `upper` limits, so `log(mu)` is the expected log biomass and each
#' survey is weighted by the precision of its in situ biomass estimate.
#'
#' `mu` is a floor plus a term proportional to the plot's tide-corrected
#' canopy cover, `mu = biomass_floor + cover_slope * exp(site_effect +
#' year_effect) * cover`, so `cover_slope` is the wet biomass per m² of
#' canopy at a typical site and year, and `biomass_floor`, common to all
#' sites and years, is the wet biomass of a plot with no delineated canopy.
#'
#' `cover` is the canopy area increased by `tide_height_slope` per metre of
#' tide height, since less of the canopy is visible at the surface at higher
#' tides, divided by the plot area and capped at 1. The default prior on
#' `tide_height_slope` is informative and largely sets the tide correction,
#' because calibration data rarely separate tide height from other
#' differences between surveys.
#'
#' @inheritSection params Sampling
#' @inheritParams kb_fit_weight_nereo
#' @inheritParams params
#' @param data A data frame of drone surveys, one row per survey (see
#'   [kb_check_data_cover_biomass_nereo()] for the required columns).
#' @param biomass A data frame of in situ wet biomass (kg/m²), one row per
#'   site-year, with `site`, `year`, `estimate`, `lower`, and `upper` columns,
#'   such as wet biomass from [kb_predict_plot_biomass()].
#' @param priors A named list of prior objects (see
#'   [kb_priors_cover_biomass_nereo()]), or `NULL` to use the defaults. Entries
#'   not supplied keep their defaults.
#' @param conf_level A number greater than 0 and less than 1 giving the level
#'   of the compatibility limits in `biomass`, or `NULL` to use the level
#'   stored in a `kb_predictions` object, or 0.95 for any other data frame.
#'
#' @returns An object of class
#'   `c("kb_fit_cover_biomass_nereo", "kb_fit_cover_biomass", "kb_fit")`. Its `data` holds the
#'   fitted surveys with the paired `estimate`, `lower`, and `upper` columns.
#' @family fit functions
#' @export
#'
#' @examples
#' # A pre-fit example model is included with the package:
#' tidy(fit_cover_biomass_sim_nereo)
#' @examplesIf interactive()
#' fit <- kb_fit_cover_biomass_nereo(data_cover_biomass_sim_nereo, data_plot_biomass_sim_nereo)
#' tidy(fit)
kb_fit_cover_biomass_nereo <- function(
  data,
  biomass,
  priors = NULL,
  ...,
  conf_level = NULL,
  prior_only = FALSE,
  chains = 4L,
  niters = 1000L,
  nthin = 1L,
  cores = NULL,
  seed = NULL,
  progress = c("bar", "verbose", "none"),
  progress_dir = NULL
) {
  rlang::check_required(biomass)
  fit_cover_biomass_model(
    data,
    biomass,
    priors,
    species = "nereocystis",
    check_data = kb_check_data_cover_biomass_nereo,
    defaults = kb_priors_cover_biomass_nereo(),
    ...,
    conf_level = conf_level,
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
