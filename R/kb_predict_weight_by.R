#' Predict Weight Over a Diameter Sequence by Grouping Factor
#'
#' Summarise the fitted relationship between weight and diameter over a generated
#' prediction grid: a sequence of diameter values crossed with the grouping factors
#' named in `by` (one curve per group). Returns a `kb_predictions` object ready for
#' [kb_plot_predictions()].
#'
#' @details
#' `by` selects the grouping factors that each get their own curve, conditioned on
#' their estimated random effects. `new_levels` controls the factors not named in
#' `by`. The default `"average"` holds those random effects at zero, giving the
#' typical-group curve. `"sample"` instead draws a new random effect from its
#' estimated distribution, widening the band to include between-group variation;
#' it draws fresh values on each call, so set a seed with `set.seed()` for a
#' reproducible band. The available `by` values are `NULL` (a single population
#' curve), `"site"`, and `c("site", "year")`.
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
#' @seealso [kb_predict_weight()] for predictions at the rows of a supplied data
#'   frame.
#' @export
#'
#' @examples
#' kb_predict_weight_by(fit_weight_hakai_nereo, by = "site")
kb_predict_weight_by <- function(fit,
                                 by = NULL,
                                 new_levels = c("average", "sample"),
                                 diameter = NULL,
                                 conf_level = 0.95,
                                 estimate = stats::median,
                                 sig_fig = 3) {
  .chk_kb_fit_weight(fit)
  .chk_summary_args(conf_level, estimate, sig_fig)

  res <- weight_by_linpred(fit, by, new_levels, diameter)
  summarise_weight_predictions(
    res$grid, res$linpred, res$by,
    conf_level = conf_level, estimate = estimate, sig_fig = sig_fig,
    curve = TRUE
  )
}
