#' Coefficients of a Model Fit
#'
#' A wrapper on [tidy()] returning the model-term posterior summaries.
#'
#' @param object A `kb_fit` object.
#' @param ... Passed to [tidy()].
#'
#' @return A tibble with one row per term and columns `term`, `estimate`,
#'   `lower`, and `upper`.
#' @family generics
#' @exportS3Method stats::coef
#' @examples
#' coef(fit_weight_sim_nereo)
coef.kb_fit <- function(object, ...) {
  tidy(object, ...)
}
