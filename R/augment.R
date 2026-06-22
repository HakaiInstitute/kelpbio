#' Augment Weight Data with Fitted Values
#'
#' Return the input data with the [fitted()] weight and deviance [residuals()]
#' point estimates appended, for residual diagnostics. Only the point estimates
#' are added; for intervals call [fitted()]/[residuals()] directly, and for
#' prediction intervals at supplied rows use [kb_predict_weight()].
#'
#' @param x A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return The input data with added columns `fitted` (response-scale fitted
#'   weight) and `residual` (deviance residual).
#' @family generics
#' @seealso [fitted()], [residuals()], and [kb_predict_weight()] for predictions
#'   at supplied rows.
#' @exportS3Method generics::augment
#' @examples
#' augment(fit_weight_hakai_nereo)
augment.kb_fit_weight <- function(x, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit_weight(x)
  dplyr::mutate(
    tibble::as_tibble(x$data),
    fitted = stats::fitted(x)$estimate,
    residual = stats::residuals(x)$estimate
  )
}
