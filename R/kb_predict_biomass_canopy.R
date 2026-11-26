#' Predict biomass over mapped canopy
#'
#' Predict the biomass over each row's mapped canopy from a cover
#' calibration fit: wet, dry, carbon, or nitrogen (kg), optionally pooled by
#' grouping columns.
#'
#' @details
#' A row's total is the calibration at full cover times its tide-corrected
#' canopy area, capped at `classified_area_m2` (see
#' [Methods](https://hakaiinstitute.github.io/kelpbio/articles/methods.html#total-biomass)).
#'
#' A total is a snapshot of the kelp present when the site is mapped, and each
#' row is assumed to map the whole site; a site flown in parts should be
#' combined into one row first. Several maps within a site-year are therefore
#' repeated measurements of one bed. With `pool_by`, the maps of each site-year
#' in a group are first averaged and the site-year means then summed, so a bed
#' is never counted more than once.
#'
#' A warning is given if a row with canopy has a tide height above 2 m, or if
#' the maps of a site-year have `classified_area_m2` values that differ by more
#' than half, which suggests maps of parts of the site.
#'
#' @inheritParams derived_params
#' @inheritParams params
#' @param fit A `kb_fit_cover_calibration` object.
#' @param new_data A data frame of canopy maps, one row per map (see
#'   [kb_check_data_survey_canopy()] for the columns). Other columns are kept
#'   and can be named in `pool_by`.
#'   `year` may be numeric or character: `2022` and `"2022"` match the same
#'   fitted year.
#'
#' @returns A `kb_predictions` object: the rows of `new_data`, or one row per
#'   `pool_by` group, with `cover_support` (when the rows have a site and
#'   year), the draws of the total (`biomass_kg`, `dry_biomass_kg`,
#'   `carbon_biomass_kg`, or `nitrogen_biomass_kg`), and `estimate`, `lower`,
#'   and `upper`.
#' @family prediction functions
#' @seealso [kb_predict_cover_calibration()] for biomass per m² of a plot.
#' @export
#'
#' @examples
#' fit <- fit_cover_calibration_sim_nereo
#'
#' # One total per row
#' set.seed(1)
#' kb_predict_biomass_canopy(fit, data_survey_canopy_sim_nereo)
#'
#' # Wet totals by region and year
#' set.seed(1)
#' kb_predict_biomass_canopy(
#'   fit,
#'   data_survey_canopy_sim_nereo,
#'   pool_by = c("region", "year")
#' )
#'
#' # Carbon stock by year
#' set.seed(1)
#' kb_predict_biomass_canopy(
#'   fit,
#'   data_survey_canopy_sim_nereo,
#'   fit_wetdry_sim_nereo,
#'   fit_carbon_sim_nereo,
#'   measure = "carbon",
#'   pool_by = "year"
#' )
kb_predict_biomass_canopy <- function(
  fit,
  new_data,
  wetdry = NULL,
  carbon = NULL,
  nitrogen = NULL,
  ...,
  measure = c("wet", "dry", "carbon", "nitrogen"),
  pool_by = NULL,
  new_levels = c("sample", "average"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit, "kb_fit_cover_calibration")
  rlang::check_required(new_data)
  measure <- rlang::arg_match(measure)
  new_levels <- rlang::arg_match(new_levels)
  .with_call(
    {
      .chk_canopy_maps(new_data, x_name = "`new_data`")
      .chk_rows(new_data, "`new_data`")
    },
    rlang::current_env()
  )
  new_data <- ids_as_character(new_data)
  .chk_pool_by(pool_by, new_data)
  pool_by <- unique(pool_by)
  .chk_measure_fits(measure, wetdry, carbon, nitrogen)
  .chk_derived_fits(list(
    fit = fit,
    wetdry = wetdry,
    carbon = carbon,
    nitrogen = nitrogen
  ))
  .chk_representative_site(fit, representative_site)
  .chk_summary_args(conf_level, estimate, sig_fig)
  warn_implausible_units(new_data, "`new_data`")
  warn_high_tide(new_data, "`new_data`", rows = "row")
  warn_partial_maps(new_data, "`new_data`")

  grid <- tibble::as_tibble(new_data)
  draws <- canopy_biomass_draws(fit, grid, new_levels, representative_site) *
    measure_factor(measure, wetdry, carbon, nitrogen)

  if (is.null(pool_by)) {
    group_vars <- .group_vars()
  } else {
    pooled <- pool_draws_by(grid, draws, pool_by, average_by = .group_vars())
    grid <- pooled$groups
    draws <- pooled$draws
    group_vars <- pool_by
  }
  grid <- with_support(grid, fit)
  summarise_draws_rows(
    grid,
    posterior::rvar(draws, nchains = posterior::nchains(fit$draws)),
    group_vars = group_vars,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    curve = FALSE,
    predictor = NULL,
    response = derived_response(measure, per_area = FALSE),
    keep_draws = TRUE
  )
}
