#' Coefficients of a Weight Model Fit
#'
#' A pure wrapper on [tidy()][tidy.kb_fit_weight], matching the `bboutools` /
#' `ssdtools` convention. Returns the model-term posterior summaries.
#'
#' @param object A `kb_fit_weight` object.
#' @param ... Passed to [tidy()][tidy.kb_fit_weight].
#'
#' @return A tibble with one row per term and columns `term`, `estimate`,
#'   `lower`, `upper`.
#' @family generics
#' @exportS3Method stats::coef
coef.kb_fit_weight <- function(object, ...) {
  tidy(object, ...)
}
