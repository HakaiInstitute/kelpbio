#' Predict Cover-Model Biomass
#'
#' Predict the expected wet biomass (kg/m²) of a plot from its canopy area, plot
#' area, and tide height, at each row of `new_data`, or at the observed surveys
#' when `new_data = NULL`.
#'
#' @details
#' Each row is tide-corrected with the fitted `bTide` and capped at a cover of 1
#' before the calibration is applied. A row with no canopy predicts the biomass
#' floor, which is the same for every site and year. For curves over
#' tide-corrected cover by site or year, build the rows with [kb_new_data()].
#'
#' Each row is resolved on its own: a `site` or `year` the model has seen is
#' conditioned on its estimated effect, and a new or absent site or year follows
#' `new_levels`. With the default `"average"`, an unseen site is the typical
#' site; use `"sample"` for an interval that includes the variation between
#' sites. For a new site, `representative_site` instead borrows the site effect of
#' one or more named fitted sites (the per-draw average across several).
#'
#' When `new_data = NULL`, the observed data's `estimate`, `lower`, and `upper`
#' columns (the in situ biomass) are replaced by the prediction; [augment()]
#' keeps them alongside the fitted values.
#'
#' @inheritParams params
#' @param fit A `kb_fit_cover_biomass` object.
#' @param new_data A data frame with `canopy_area_m2` (canopy area in the plot,
#'   m²), `plot_area_m2` (plot area, m²), and `tide_height_m` (tide height, m)
#'   columns and optional `site` and `year` columns, one row per prediction, or
#'   `NULL` to predict at the observed surveys.
#' @param ... Unused.
#'
#' @return A `kb_predictions` object: the rows of `new_data` with added
#'   `estimate`, `lower`, and `upper` columns summarising the posterior
#'   distribution of the expected wet biomass per m² of plot.
#' @family prediction
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
#' # At your own surveys, including a new site:
#' kb_predict_cover_biomass(
#'   fit,
#'   data.frame(
#'     site = c("site1", "new_site"),
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
  .chk_kb_fit_cover_biomass(fit)
  .chk_by_habit(new_data, ..., verb = "kb_predict_cover_biomass")
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
