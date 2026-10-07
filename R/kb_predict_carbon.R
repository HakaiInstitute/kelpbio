#' Predict the Carbon Fraction
#'
#' Summarise the expected carbon fraction of dry mass for the population of
#' samples the model was fitted to.
#'
#' @details
#' The model has no grouping factors or predictor, so the prediction is a single
#' estimate: the mean of the fitted Beta distribution. It describes the samples
#' as supplied, pooled over the months, sites, and tissues they come from; for a
#' particular season, fit the model to that season's samples.
#'
#' @inheritParams params
#' @param fit A `kb_fit_carbon` object.
#' @param ... Unused.
#'
#' @return A `kb_predictions` object: a one-row tibble with `estimate`, `lower`,
#'   and `upper` columns summarising the posterior distribution of the expected
#'   carbon fraction.
#' @family prediction
#' @seealso [posterior_predict()] for draws of individual sample fractions.
#' @export
#'
#' @examples
#' kb_predict_carbon(fit_carbon_sim_nereo)
kb_predict_carbon <- function(
  fit,
  ...,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  .chk_kb_fit(fit, "kb_fit_carbon")
  rlang::check_dots_empty()
  .chk_summary_args(conf_level, estimate, sig_fig)

  res <- data_linpred(fit, tibble::tibble(.rows = 1L), new_levels = "average")
  summarise_predictions(
    fit,
    res$grid,
    res$linpred,
    res$group_vars,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig
  )
}
