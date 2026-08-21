#' Pointwise Log-Likelihood
#'
#' The pointwise log-likelihood of the observed data, suitable for `loo::loo()`.
#'
#' @details
#' Computed from the stored draws by evaluating the model's likelihood at the
#' observed data.
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
  .log_lik(object, mu)
}

# Pointwise log-likelihood, D x N and unreduced. Preallocate at that orientation:
# loo() accepts a transposed matrix and silently reports elpd over draws.
.log_lik <- function(fit, mu) {
  UseMethod(".log_lik")
}

#' @export
.log_lik.default <- function(fit, mu) {
  .abort_no_method(x = fit, call = NULL)
}

#' @export
.log_lik.kb_fit_weight_nereo <- function(fit, mu) {
  sw <- as.vector(posterior::draws_of(fit$draws$sWeight))
  y <- log(fit$data$weight)
  theta <- 1 / fit$meta$nu
  out <- matrix(NA_real_, nrow = nrow(mu), ncol = length(y))
  for (d in seq_len(nrow(mu))) {
    out[d, ] <- extras::log_lik_student(y, mu[d, ], sd = sw[d], theta = theta)
  }
  out
}

#' @export
.log_lik.kb_fit_weight_macro <- function(fit, mu) {
  ewt <- exp(mu)
  y <- fit$data$weight
  shape <- as.vector(posterior::draws_of(fit$draws$shape))
  out <- matrix(NA_real_, nrow = nrow(mu), ncol = length(y))
  for (d in seq_len(nrow(mu))) {
    out[d, ] <- extras::log_lik_gamma(
      y,
      shape = shape[d],
      rate = shape[d] / ewt[d, ]
    )
  }
  out
}
