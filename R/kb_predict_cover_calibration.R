#' Predict biomass from canopy cover
#'
#' Predict the expected wet biomass (kg/m²) of a plot from its drone canopy
#' cover.
#'
#' @details
#' Cover is tide-corrected and capped at 1, as in the fit; a row with canopy at
#' a tide height at or above `1 / tide_height_slope` is fully covered, and a
#' row past that limit on more than 5% of draws warns. Canopy already corrected
#' for tide is passed with
#' `tide_height_m = 0`. A row with no canopy predicts the biomass floor, which
#' is the same for every site and year.
#'
#' The prediction is `mu`, the mean before censoring at zero, as used by
#' [kb_predict_biomass_canopy()]. When `new_data = NULL`, the survey biomass
#' columns are kept; use [augment()] for the fitted values next to them.
#'
#' @inheritParams params
#' @param fit A `kb_fit_cover_calibration` object.
#' @param new_data A data frame of the rows to predict at, with
#'   `canopy_area_m2` (the canopy area in the plot, m²), `plot_area_m2` (the
#'   plot area, m²), `tide_height_m` (the tide height, m), and optionally `site`
#'   and `year`, or `NULL` for the observed surveys.
#'
#' @returns A `kb_predictions` object: the rows of `new_data` with added
#'   `estimate`, `lower`, and `upper` columns summarising the posterior
#'   distribution of the expected wet biomass per m² of plot. When the rows
#'   have `site` and `year`, a `cover_support` column (as in
#'   [kb_predict_biomass_canopy()]) precedes the summary.
#' @family prediction functions
#' @seealso [kb_new_data()] to build rows by site or year over tide-corrected
#'   cover.
#' @export
#'
#' @examples
#' fit <- fit_cover_calibration_sim_nereo
#'
#' # At the observed surveys
#' kb_predict_cover_calibration(fit)
#'
#' # Curves over tide-corrected cover by site
#' kb_predict_cover_calibration(fit, kb_new_data(fit, by = "site"))
#'
#' # At new surveys, including a new site
#' kb_predict_cover_calibration(
#'   fit,
#'   data.frame(
#'     site = c("otter_cove", "new_site"),
#'     canopy_area_m2 = 80,
#'     plot_area_m2 = 200,
#'     tide_height_m = 0.5
#'   )
#' )
kb_predict_cover_calibration <- function(
  fit,
  new_data = NULL,
  ...,
  new_levels = c("average", "sample"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  .chk_kb_fit(fit, "kb_fit_cover_calibration")
  rlang::check_dots_empty()
  predictions <- predict_rows(
    fit,
    new_data,
    new_levels,
    representative_site,
    conf_level,
    estimate,
    sig_fig
  )
  if (!is.null(new_data)) {
    warn_tide_cap(
      tide_cap_share(new_data$canopy_area_m2, new_data$tide_height_m, fit$draws$tide_height_slope),
      "`new_data`",
      rows = "row",
      cap = "the plot area (full cover)",
      basis = "on more than 5% of draws"
    )
  }
  predictions
}
