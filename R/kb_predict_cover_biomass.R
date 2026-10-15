#' Predict biomass from canopy cover
#'
#' Predict the expected wet biomass (kg/m²) of a plot from its canopy area, plot
#' area, and tide height, at each row of `new_data`, or at the observed surveys
#' when `new_data = NULL`.
#'
#' @details
#' Cover is tide-corrected and capped at 1. A row with no canopy predicts the
#' biomass floor, which is the same for every site and year.
#'
#' When `new_data = NULL`, the in situ biomass columns are replaced by the
#' prediction; use [augment()] to keep both.
#'
#' @inheritParams params
#' @param fit A `kb_fit_cover_biomass` object.
#' @param new_data A data frame with `canopy_area_m2` (canopy area in the plot,
#'   m²), `plot_area_m2` (plot area, m²), and `tide_height_m` (tide height, m)
#'   columns and optional `site` and `year` columns, one row per prediction, or
#'   `NULL` to predict at the observed surveys.
#'
#' @returns A `kb_predictions` object: the rows of `new_data` with added
#'   `estimate`, `lower`, and `upper` columns summarising the posterior
#'   distribution of the expected wet biomass per m² of plot.
#' @family prediction functions
#' @seealso [kb_new_data()] to build rows by site or year over tide-corrected
#'   cover.
#' @export
#'
#' @examples
#' fit <- fit_cover_biomass_sim_nereo
#'
#' # At the observed surveys:
#' kb_predict_cover_biomass(fit)
#'
#' # Curves over tide-corrected cover by site:
#' kb_predict_cover_biomass(fit, kb_new_data(fit, by = "site"))
#'
#' # At new surveys, including a new site:
#' kb_predict_cover_biomass(
#'   fit,
#'   data.frame(
#'     site = c("otter_cove", "new_site"),
#'     canopy_area_m2 = 80,
#'     plot_area_m2 = 200,
#'     tide_height_m = 0.5
#'   )
#' )
kb_predict_cover_biomass <- function(
  fit,
  new_data = NULL,
  ...,
  new_levels = c("average", "sample"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  .chk_kb_fit(fit, "kb_fit_cover_biomass")
  rlang::check_dots_empty()
  predict_rows(
    fit,
    new_data,
    new_levels,
    representative_site,
    conf_level,
    estimate,
    sig_fig
  )
}
