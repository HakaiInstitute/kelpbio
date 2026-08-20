#' Pointwise Log-Likelihood
#'
#' The pointwise log-likelihood of the observed data, suitable for `loo::loo()`.
#'
#' @details
#' Computed from the stored draws by evaluating the model's likelihood at the
#' observed data, so it is deterministic: repeated calls return identical values.
#' The density is of the response on the scale the model fits it (log weight for
#' *Nereocystis*, weight for *Macrocystis*), with no Jacobian adjustment, matching
#' the Stan likelihood. Values are therefore comparable across models that share
#' the response scale, but not across models that do not.
#'
#' @param object A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return A draws-by-observations (`D x N`) matrix.
#' @family generics
#' @exportS3Method rstantools::log_lik
#' @examples
#' ll <- log_lik(fit_weight_sim_nereo)
#' dim(ll)
log_lik.kb_fit_weight <- function(object, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit_weight(object)
  if (nrow(object$data) == 0L) {
    cli::cli_abort(
      "A zero-observation fit has no pointwise log-likelihood."
    )
  }
  mu <- posterior::draws_of(.weight_linpred_obs(object)) # log scale, D x N
  .weight_log_lik(object, mu)
}

# Per-draw pointwise log-likelihood from the species' likelihood (mu = log-scale
# mean, D x N); dispatches on the fit subclass. The output is preallocated at the
# D x N contract rather than transposing a vapply result: a transposed matrix is
# accepted by loo::loo() without complaint and silently reports elpd over draws
# instead of observations.
.weight_log_lik <- function(object, mu) {
  UseMethod(".weight_log_lik")
}

.weight_log_lik.kb_fit_weight_nereo <- function(object, mu) {
  sw <- as.vector(posterior::draws_of(object$draws$sWeight))
  y <- log(object$data$weight)
  theta <- 1 / object$meta$nu
  out <- matrix(NA_real_, nrow = nrow(mu), ncol = length(y))
  for (d in seq_len(nrow(mu))) {
    out[d, ] <- extras::log_lik_student(y, mu[d, ], sd = sw[d], theta = theta)
  }
  out
}

.weight_log_lik.kb_fit_weight_macro <- function(object, mu) {
  ewt <- exp(mu)
  y <- object$data$weight
  shape <- as.vector(posterior::draws_of(object$draws$shape))
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
