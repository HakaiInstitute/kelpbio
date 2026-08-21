#' Augment Model Data
#'
#' Append the [fitted()] and deviance [residuals()] values
#' to the input data. Values are the point estimate (median) of the posterior distributions.
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
  # fitted() and residuals() would each resolve the observed linear predictor
  # again, so build both from one pass over the draws.
  .chk_observed_data(x)
  mu <- .linpred_obs(x)
  out <- tibble::as_tibble(x$data)
  out$fitted <- as.numeric(stats::median(.epred(x, mu)))
  out$residual <- as.numeric(apply(
    .deviance(x, posterior::draws_of(mu)),
    2L,
    stats::median
  ))
  out
}
