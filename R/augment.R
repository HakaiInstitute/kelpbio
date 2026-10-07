#' Augment Model Data
#'
#' Append the [fitted()] and deviance [residuals()] values to the input data.
#' Values are posterior medians: `fitted` of the expected response, `residual` of
#' the deviance residual.
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
  # One pass over the linear predictor for both columns.
  mu <- .linpred_obs(x)
  out <- tibble::as_tibble(x$data)
  out$fitted <- as.numeric(stats::median(.epred(x, mu)))
  res <- .eval_family(x, posterior::draws_of(mu), x$data, "res")
  out$residual <- as.numeric(apply(res, 2L, stats::median))
  out
}
