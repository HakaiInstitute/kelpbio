#' Fit a Macrocystis Cover Biomass Model
#'
#' Fit a cover-biomass calibration for *Macrocystis pyrifera* via Stan.
#'
#' @details
#' Each drone survey in `data` is paired with the in situ wet biomass of its
#' site-year in `biomass`, typically the output of a biomass prediction. Surveys
#' whose site-year has no biomass are not fitted, and a message gives their
#' site-years.
#'
#' The in situ wet biomass (kg/m²) is modelled as a floor plus a term
#' proportional to the plot's tide-corrected canopy cover:
#' `mu = biomass_floor + cover_slope * exp(site_effect + year_effect) * cover`. `cover_slope` is the wet
#' biomass per m² of canopy at a typical site and year, and `biomass_floor` the wet
#' biomass of a plot with no delineated canopy, common to all sites and years.
#' The site and year effects act on the canopy term only. Cover is the canopy
#' area increased by `tide_height_slope` per metre of tide height, since less of the canopy
#' is visible at the surface at higher tides, divided by the plot area and
#' capped at 1. The calibration data carry almost no information on `tide_height_slope`, so
#' the tide correction is set by its prior.
#'
#' The log of the biomass estimate is Normal around `log(mu)` with standard
#' deviation `error_scaling` times the log-scale SD implied by its `lower` and `upper`
#' limits, so each survey is weighted by the precision of its in situ estimate,
#' and `error_scaling` calibrates the supplied SDs.
#'
#' @inheritSection params Sampling
#' @inheritParams params
#' @param data A data frame of drone surveys, one row per survey (see
#'   [kb_check_data_cover_biomass_macro()] for the required columns).
#' @param biomass A data frame of in situ wet biomass (kg/m²), one row per
#'   site-year, with `site`, `year`, `estimate`, `lower`, and `upper` columns,
#'   such as a `kb_predictions` object from a biomass prediction.
#' @param priors A named list of prior objects (see [kb_priors_cover_biomass_macro()]),
#'   or `NULL` to use the defaults. Supplied entries override the corresponding
#'   defaults; unspecified entries keep their defaults.
#' @param conf_level A number between 0 and 1 giving the level of the
#'   compatibility limits in `biomass`, or `NULL` to use the level a
#'   `kb_predictions` object records, else 0.95.
#' @param ... Additional arguments passed to [rstan::sampling()], including a
#'   `control` list (merged over the `adapt_delta = 0.95` default); see the
#'   `control` argument of [rstan::stan()] for the available entries.
#'
#' @return An object of class
#'   `c("kb_fit_cover_biomass_macro", "kb_fit_cover_biomass", "kb_fit")`. Its `data` holds the
#'   fitted surveys with the paired `estimate`, `lower`, and `upper` columns.
#' @family model
#' @export
#'
#' @examples
#' if (interactive()) {
#'   fit <- kb_fit_cover_biomass_macro(data_cover_biomass_sim_macro, data_plot_biomass_sim_macro)
#'   tidy(fit)
#' }
#' # A pre-fit example model is included with the package:
#' tidy(fit_cover_biomass_sim_macro)
kb_fit_cover_biomass_macro <- function(
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
    species = "macrocystis",
    check_data = kb_check_data_cover_biomass_macro,
    defaults = kb_priors_cover_biomass_macro(),
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
