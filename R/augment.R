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
  # One pass over the linear predictor for both columns.
  mu <- .linpred_obs(x)
  out <- tibble::as_tibble(x$data)
  out$fitted <- as.numeric(stats::median(.epred(x, mu)))
  res <- .eval_family(x, posterior::draws_of(mu), x$data, "res")
  out$residual <- as.numeric(apply(res, 2L, stats::median))
  out
}
