#' Coefficients
#'
#' Posterior summaries of the model terms, as returned by [tidy()].
#'
#' @inheritParams params
#' @param ... Passed to [tidy()].
#'
#' @returns A tibble with one row per term and columns `term`, `estimate`,
#'   `lower`, and `upper`.
#' @family fit methods
#' @exportS3Method stats::coef
#' @examples
#' coef(fit_weight_sim_nereo)
coef.kb_fit <- function(object, ...) {
  # error_call() names the generic, not tidy().
  .with_call(tidy(object, ...), rlang::error_call(rlang::current_env()))
}
