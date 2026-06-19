#' Predict Method for a Weight Model Fit
#'
#' A thin wrapper on [kb_predict_weight()] providing the conventional
#' `stats::predict` entry point. Returns a `kb_predictions` summary tibble.
#'
#' @inheritParams params
#' @inheritParams kb_predict_weight
#' @param object A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return A `kb_predictions` object.
#' @exportS3Method stats::predict
predict.kb_fit_weight <- function(object,
                                  new_data = NULL,
                                  by = NULL,
                                  uncertainty = c("marginal", "typical"),
                                  conf_level = 0.95,
                                  estimate = stats::median,
                                  sig_fig = 3,
                                  ...) {
  rlang::check_dots_empty()
  kb_predict_weight(
    object,
    new_data = new_data,
    by = by,
    uncertainty = uncertainty,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig
  )
}
