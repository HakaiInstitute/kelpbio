#' Predict the nitrogen fraction
#'
#' Summarise the expected nitrogen fraction of dry mass for the population of
#' samples the model was fitted to.
#'
#' @details
#' A single estimate, pooled over the months, sites, and tissues of the samples
#' supplied to the fit; to estimate for one season, fit the model to that
#' season's samples.
#'
#' @inheritParams params
#' @param fit A `kb_fit_nitrogen` object.
#'
#' @returns A `kb_predictions` object: a one-row tibble with `estimate`, `lower`,
#'   and `upper` columns summarising the posterior distribution of the expected
#'   nitrogen fraction.
#' @family prediction functions
#' @seealso [posterior_predict()] for draws of individual sample fractions.
#' @export
#'
#' @examples
#' kb_predict_nitrogen(fit_nitrogen_sim_nereo)
kb_predict_nitrogen <- function(
  fit,
  ...,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  .chk_kb_fit(fit, "kb_fit_nitrogen")
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
