#' Predict Method for a Weight Model Fit
#'
#' A thin wrapper on [kb_predict_weight()] providing the conventional
#' `stats::predict` entry point: predict weight at the supplied `new_data`
#' rows (or the observed data when `new_data = NULL`). For allometric curves to
#' visualise, use [kb_predict_weight_by()].
#'
#' @inheritParams params
#' @inheritParams kb_predict_weight
#' @param object A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return A `kb_predictions` object.
#' @family generics
#' @exportS3Method stats::predict
predict.kb_fit_weight <- function(object,
                                  new_data = NULL,
                                  new_levels = c("sample", "average"),
                                  conf_level = 0.95,
                                  estimate = stats::median,
                                  sig_fig = 3,
                                  ...) {
  rlang::check_dots_empty()
  kb_predict_weight(
    object,
    new_data = new_data,
    new_levels = new_levels,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig
  )
}
