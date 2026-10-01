#' Deviance Residuals
#'
#' Posterior point estimates of the deviance residual at each observed row, from
#' the fitted likelihood, matching [augment()]'s `residual` column.
#'
#' @details
#' The deviance residual is computed per draw, then summarised with the posterior
#' median. The likelihoods are Normal on log weight (*Nereocystis* weight), Gamma
#' on weight (*Macrocystis* weight), Weibull on diameter (*Nereocystis* size), and
#' zero-truncated negative binomial on frond count (*Macrocystis* size).
#'
#' A size residual is zero where the observation equals the value that
#' maximises its likelihood with the shape or overdispersion held fixed: the
#' Weibull scale for *Nereocystis* (which exceeds the mean when the shape is
#' greater than 1), and the truncated mean for *Macrocystis*.
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
  .per_draw(mu, log(fit$data$weight), function(y, mu_d, d) {
    extras::res_norm(y, mu_d, sd = sw[d])
  })
}

#' @export
.deviance.kb_fit_weight_macro <- function(fit, mu) {
  shape <- as.vector(posterior::draws_of(fit$draws$bShape))
  .per_draw(mu, fit$data$weight, function(y, mu_d, d) {
    extras::res_gamma(y, shape = shape[d], rate = shape[d] / exp(mu_d))
  })
}

#' @export
.deviance.kb_fit_size_nereo <- function(fit, mu) {
  shape <- as.vector(posterior::draws_of(fit$draws$bShape))
  .per_draw(mu, fit$data$diameter, function(y, mu_d, d) {
    res_weibull(y, shape[d], weibull_scale(exp(mu_d), shape[d]))
  })
}

#' @export
.deviance.kb_fit_size_macro <- function(fit, mu) {
  theta <- as.vector(posterior::draws_of(fit$draws$bDispersion))
  .per_draw(mu, fit$data$fronds, function(y, mu_d, d) {
    res_gamma_pois_zt(y, exp(mu_d), theta[d])
  })
}
