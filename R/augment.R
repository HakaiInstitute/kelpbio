#' Add fitted values and residuals to the data
#'
#' Append the [fitted()] and deviance [residuals()] values to the input data.
#'
#'
#' @inheritParams params
#' @returns The input data with added columns `fitted` (the posterior median of
#'   the expected response) and `residual` (the posterior median of the
#'   deviance residual).
#' @family fit methods
#' @seealso [fitted()] and [residuals()].
#' @exportS3Method generics::augment
#' @examples
#' augment(fit_weight_sim_nereo)
augment.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(x)
  # Checked here so a zero-row fit's error names augment(), not fitted().
  .chk_observed_data(x)
  out <- tibble::as_tibble(x$data)
  out$fitted <- fitted(x)
  out$residual <- residuals(x)
  out
}
