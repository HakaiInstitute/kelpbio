#' Deviance Residuals
#'
#' Posterior point estimates of the deviance residual at each observed row, from
#' the fitted likelihood (Student-t on log-weight for *Nereocystis*, Gamma on
#' weight for *Macrocystis*), matching [augment()]'s `residual` column.
#'
#' @details
#' The deviance residual is computed per draw, then summarised with the posterior
#' median.
#'
#' @param object A `kb_fit` object.
#' @param ... Unused.
#'
#' @return A numeric vector of deviance residuals, length `nobs(object)`.
#' @family generics
#' @seealso [fitted()] for fitted values, and [augment()].
#' @exportS3Method stats::residuals
#' @examples
#' residuals(fit_weight_sim_nereo)
residuals.kb_fit <- function(object, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(object)
  mu <- posterior::draws_of(.linpred_obs(object)) # link scale, D x N
  as.numeric(apply(.deviance(object, mu), 2L, stats::median))
}

# Deviance residuals, D x N and unreduced like .log_lik; shape from .per_draw().
.deviance <- function(fit, mu) {
  UseMethod(".deviance")
}

#' @export
.deviance.default <- function(fit, mu) {
  .abort_no_method(x = fit, call = NULL)
}

#' @export
.deviance.kb_fit_weight_nereo <- function(fit, mu) {
  sw <- as.vector(posterior::draws_of(fit$draws$sWeight))
  # nu is estimated, so theta is per-draw like the residual scale beside it.
  nu <- as.vector(posterior::draws_of(fit$draws$bNu))
  .per_draw(mu, log(fit$data$weight), function(y, mu_d, d) {
    extras::res_student(y, mu_d, sd = sw[d], theta = 1 / nu[d])
  })
}

#' @export
.deviance.kb_fit_weight_macro <- function(fit, mu) {
  shape <- as.vector(posterior::draws_of(fit$draws$shape))
  .per_draw(mu, fit$data$weight, function(y, mu_d, d) {
    extras::res_gamma(y, shape = shape[d], rate = shape[d] / exp(mu_d))
  })
}
