#' Predict biomass over mapped canopy
#'
#' Predict the biomass over each row's drone-mapped canopy from a cover
#' calibration fit: wet or dry (kg or kg/m²) or carbon (kg C or g C/m²),
#' optionally pooled over groups of rows.
#'
#' @details
#' A row's total is the expected biomass per m² of bed for its site and year
#' (the calibration at full cover) times its tide-corrected canopy area: the
#' canopy divided by one minus the tide slope times the tide height, capped at
#' `site_area_m2` where given. The mapped canopy is taken as the extent of the
#' bed, so no biomass is counted outside it. The interval is for the expected
#' total: it carries the uncertainty in the parameters and the site and year
#' effects, not variation between flights. With `per_area = TRUE` the total is
#' divided by the tide-corrected canopy area, giving the biomass per m² of bed.
#'
#' Dry biomass is the wet total times the expected dry:wet ratio from `wetdry`,
#' and carbon the dry total times the expected carbon fraction from `carbon`.
#'
#' Totals are pooled within `pool_by` groups on each draw, so do not sum
#' per-row estimates or limits. Sum at most one row per site-year; a group with
#' more warns.
#'
#' @inheritParams derived_params
#' @inheritParams params
#' @param fit A `kb_fit_cover_calibration` object.
#' @param new_data A data frame with one row per mapped canopy: `site`, `year`,
#'   `canopy_area_m2` (the canopy mapped within the site, m²), and
#'   `tide_height_m` (tide height at the flight, m), and optionally
#'   `site_area_m2` (the area within the site boundary, m²), which caps the
#'   tide-corrected canopy. Other columns are kept, and can be named in `pool_by`.
#' @param measure A string, one of `"wet"`, `"dry"`, or `"carbon"`, giving the
#'   biomass to predict.
#' @param per_area A flag specifying whether to give biomass per m² of
#'   tide-corrected canopy, or else the total over the canopy.
#'
#' @returns A `kb_predictions` object. Without `pool_by`, the rows of `new_data`
#'   with added `cover_support` (`"site, year"`, `"site"`, `"year"`, or
#'   `"none"`: the data the calibration fit has for the row's site and year), the
#'   draws of the biomass in a column named for it (`biomass_kg`,
#'   `dry_biomass_kg`, or `carbon_biomass_kg` in total, and `biomass_kg_m2`,
#'   `dry_biomass_kg_m2`, or `carbon_biomass_g_m2` per m²), and `estimate`,
#'   `lower`, and `upper`; with `pool_by`, one row per group with its `pool_by`
#'   columns, the draws, and the summary.
#' @family prediction functions
#' @seealso [kb_predict_cover_calibration()] for biomass per m² of a plot at a
#'   given cover.
#' @export
#'
#' @examples
#' fit <- fit_cover_calibration_sim_nereo
#'
#' # One total per row
#' set.seed(1)
#' kb_predict_biomass_canopy(fit, data_canopy_sim_nereo)
#'
#' # Wet totals by year
#' set.seed(1)
#' kb_predict_biomass_canopy(fit, data_canopy_sim_nereo, pool_by = "year")
#'
#' # Carbon stock by year
#' set.seed(1)
#' kb_predict_biomass_canopy(
#'   fit,
#'   data_canopy_sim_nereo,
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
  ...,
  measure = c("wet", "dry", "carbon"),
  per_area = FALSE,
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
  chk::chk_flag(per_area)
  .with_call(
    {
      .chk_site_surveys(new_data, x_name = "`new_data`")
      .chk_rows(new_data, "`new_data`")
    },
    rlang::current_env()
  )
  warn_implausible_units(new_data, "`new_data`")
  .chk_pool_by(pool_by, new_data)
  .chk_measure_fits(measure, wetdry, carbon)
  .chk_derived_fits(list(fit = fit, wetdry = wetdry, carbon = carbon))
  .chk_representative_site(fit, representative_site)
  .chk_summary_args(conf_level, estimate, sig_fig)

  grid <- tibble::as_tibble(new_data)
  canopy <- canopy_biomass_draws(fit, grid, new_levels, representative_site)
  carbon_scale <- if (per_area) 1000 else 1
  totals <- canopy$biomass *
    measure_factor(measure, wetdry, carbon, carbon_scale = carbon_scale)
  area <- if (per_area) canopy$canopy

  if (is.null(pool_by)) {
    grid$cover_support <- cover_support(fit, grid$site, grid$year)
    draws <- if (per_area) totals / area else totals
    group_vars <- .group_vars()
  } else {
    pooled <- pool_draws_by(grid, totals, pool_by, area = area)
    warn_overlapping_canopy(grid, pooled$id)
    grid <- pooled$groups
    draws <- pooled$draws
    group_vars <- pool_by
  }
  summarise_draws_rows(
    grid,
    posterior::rvar(draws, nchains = posterior::nchains(fit$draws)),
    group_vars = group_vars,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    curve = FALSE,
    predictor = NULL,
    response = derived_response(measure, per_area),
    keep_draws = TRUE
  )
}
