#' Predict Weight Over a Predictor Sequence by Grouping Factor
#'
#' Summarise the fitted allometric relationship over a generated prediction grid:
#' a sequence of predictor values (diameter for *Nereocystis*, fronds for
#' *Macrocystis*) crossed with the grouping factors named in `by` (one curve per
#' group).
#'
#' @details
#' `by` selects the grouping factors that each get their own curve, conditioned on
#' their estimated random effects. `new_levels` controls the factors not named in
#' `by`. The default `"average"` holds those random effects at zero, giving the
#' typical-group curve. `"sample"` instead draws a new random effect from its
#' estimated distribution, widening the uncertainty to include between-group
#' variation. Set a seed with `set.seed()` for reproducible CIs.
#'
#' The available `by` values are `NULL` (a single population curve), `"site"`, and
#' `c("site", "year")` for both species; the *Macrocystis* model additionally
#' allows `"year"`, since it has a year main effect (the *Nereocystis* model does
#' not, so `by = "year"` errors there).
#'
#' @inheritParams params
#' @param fit A `kb_fit_weight` object.
#' @param predictor A numeric vector of predictor values to predict over (diameter
#'   for *Nereocystis*, fronds for *Macrocystis*, in the same units as the fitted
#'   data), or `NULL` for an automatic sequence spanning the observed range.
#'
#' @return A `kb_predictions` object: a summary tibble with `estimate`, `lower`,
#'   `upper`, the predictor column, and the `by` grouping columns.
#' @family prediction
#' @seealso [kb_predict_weight()] for predictions at the rows of a supplied data
#'   frame.
#' @export
#'
#' @examples
#' kb_predict_weight_by(fit_weight_sim_nereo, by = "site")
kb_predict_weight_by <- function(
  fit,
  by = NULL,
  predictor = NULL,
  ...,
  new_levels = c("average", "sample"),
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  rlang::check_dots_empty()
  .chk_kb_fit_weight(fit)
  .chk_summary_args(conf_level, estimate, sig_fig)

  res <- weight_by_linpred(fit, by, new_levels, predictor)
  summarise_weight_predictions(
    res$grid,
    res$linpred,
    res$by,
    predictor = fit$meta$predictor %||% "diameter",
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    curve = TRUE
  )
}
