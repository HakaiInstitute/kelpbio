#' Allometric Weight Curves
#'
#' Summarise the fitted weight-at-diameter relationship over a diameter sequence,
#' as a `kb_predictions` object ready for [kb_plot_predictions()]. It builds the
#' diameter sequence automatically. To predict weight for a data frame of measured
#' diameters, use [kb_predict_weight()].
#'
#' @details
#' `by` selects the grouping factors that each get their own curve, conditioned on
#' their estimated random effects. `new_levels` controls the factors not named in
#' `by`: `"sample"` (a new, unsampled group, widening the band to include
#' between-group variation) or `"average"` (the typical group, random effects held
#' at zero). The available `by` values are `NULL` (a single population curve),
#' `"site"`, and `c("site", "year")`. `"average"` reports the typical-group
#' prediction, not a calibrated interval for a specific new group.
#'
#' @inheritParams params
#' @param fit A `kb_fit_weight` object.
#' @param diameter A numeric vector of sub-bulb diameters to predict over (in the
#'   same units as the fitted data), or `NULL` for an automatic sequence spanning
#'   the observed range.
#'
#' @return A `kb_predictions` object: a summary tibble with `estimate`, `lower`,
#'   `upper`, the `diameter` predictor, and the `by` grouping columns.
#' @family prediction
#' @seealso [kb_predict_weight()] for predictions at supplied rows.
#' @export
#'
#' @examples
#' kb_predict_weight_by(fit_weight, by = "site")
kb_predict_weight_by <- function(fit,
                                 by = NULL,
                                 new_levels = c("sample", "average"),
                                 diameter = NULL,
                                 conf_level = 0.95,
                                 estimate = stats::median,
                                 sig_fig = 3) {
  .chk_kb_fit_weight(fit)
  chk::chk_number(conf_level)
  chk::chk_range(conf_level)
  chk::chk_function(estimate)
  chk::chk_whole_number(sig_fig)
  chk::chk_gt(sig_fig, value = 0)

  res <- weight_by_linpred(fit, by, new_levels, diameter)
  summarise_weight_predictions(
    res$grid, res$linpred, res$by,
    conf_level = conf_level, estimate = estimate, sig_fig = sig_fig
  )
}
