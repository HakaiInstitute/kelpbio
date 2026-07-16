#' Augment Model Data
#'
#' Append the [fitted()] values and deviance [residuals()]
#' to the input data. The columns come straight from the
#' `fitted()` and `residuals()` methods, so they cannot diverge from them.
#'
#' @param x A `kb_fit` object.
#' @param ... Unused.
#'
#' @return The input data with added columns `fitted` (response-scale fitted
#'   value) and `residual` (deviance residual).
#' @family generics
#' @seealso [fitted()] and [residuals()].
#' @exportS3Method generics::augment
#' @examples
#' augment(fit_weight_sim_nereo)
augment.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(x)
  out <- tibble::as_tibble(x$data)
  out$fitted <- stats::fitted(x)
  out$residual <- stats::residuals(x)
  out
}
