#' Coefficients of a Weight Model Fit
#'
#' A wrapper on [tidy()][tidy.kb_fit_weight] returning the model-term posterior
#' summaries.
#'
#' @param object A `kb_fit_weight` object.
#' @param ... Passed to [tidy()][tidy.kb_fit_weight].
#'
#' @return A tibble with one row per term and columns `term`, `estimate`,
#'   `lower`, and `upper`.
#' @family generics
#' @exportS3Method stats::coef
#' @examples
#' coef(fit_weight)
coef.kb_fit_weight <- function(object, ...) {
  tidy(object, ...)
}
