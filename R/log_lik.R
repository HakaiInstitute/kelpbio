#' Pointwise log-likelihood
#'
#' The pointwise log-likelihood of the observed data, suitable for [loo::loo()].
#'
#' @details
#' Each value is the log density of the response as recorded (for example
#' weight in kg, not log weight), so models of the same response can be
#' compared with [loo::loo_compare()].
#'
#'
#' @inheritParams params
#' @returns A draws-by-observations (`D x N`) matrix.
#' @family fit methods
#' @seealso [loo.kb_fit()] for leave-one-out cross-validation of a fit.
#' @exportS3Method rstantools::log_lik
#' @examples
#' ll <- log_lik(fit_weight_sim_nereo)
#' dim(ll)
log_lik.kb_fit <- function(object, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(object)
  mu <- posterior::draws_of(.linpred_obs(object)) # link scale, D x N
  .eval_family(object, mu, object$data, "log_lik")
}
