#' Pointwise Log-Likelihood
#'
#' The pointwise log-likelihood of the observed data, suitable for `loo::loo()`.
#'
#' @details
#' Computed from the stored draws by evaluating the model's likelihood at the
#' observed data. Each value is the log density of the response as recorded (for
#' example weight in kg, not log weight), so models of the same response can be
#' compared with `loo::loo_compare()`.
#'
#' @param object A `kb_fit` object.
#' @param ... Unused.
#'
#' @return A draws-by-observations (`D x N`) matrix.
#' @family generics
#' @exportS3Method rstantools::log_lik
#' @examples
#' ll <- log_lik(fit_weight_sim_nereo)
#' dim(ll)
log_lik.kb_fit <- function(object, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(object)
  if (nrow(object$data) == 0L) {
    cli::cli_abort(
      "A zero-observation fit has no pointwise log-likelihood."
    )
  }
  mu <- posterior::draws_of(.linpred_obs(object)) # link scale, D x N
  .eval_family(object, mu, object$data, "log_lik")
}
