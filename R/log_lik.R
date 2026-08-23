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

# Pointwise log-likelihood, D x N and unreduced; see .per_draw() for the shape.
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
  theta <- 1 / fit$meta$nu
  .per_draw(mu, log(fit$data$weight), function(y, mu_d, d) {
    extras::log_lik_student(y, mu_d, sd = sw[d], theta = theta)
  })
}

#' @export
.log_lik.kb_fit_weight_macro <- function(fit, mu) {
  shape <- as.vector(posterior::draws_of(fit$draws$shape))
  .per_draw(mu, fit$data$weight, function(y, mu_d, d) {
    extras::log_lik_gamma(y, shape = shape[d], rate = shape[d] / exp(mu_d))
  })
}
