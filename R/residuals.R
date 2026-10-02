#' Deviance Residuals
#'
#' Posterior point estimates of the deviance residual at each observed row, from
#' the fitted likelihood, matching [augment()]'s `residual` column.
#'
#' @details
#' The deviance residual is computed per draw, then summarised with the posterior
#' median. The likelihoods are Normal on log weight (*Nereocystis* weight), Gamma
#' on weight (*Macrocystis* weight), Weibull on diameter (*Nereocystis* size),
#' zero-truncated negative binomial on frond count (*Macrocystis* size),
#' zero-inflated negative binomial on stipe count (*Nereocystis* density),
#' negative binomial on plant count (*Macrocystis* density), and Beta on the
#' dry:wet mass ratio (wet/dry).
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
  .per_draw(mu, log(fit$data$weight_kg), function(y, mu_d, d) {
    extras::res_norm(y, mu_d, sd = sw[d])
  })
}

#' @export
.deviance.kb_fit_weight_macro <- function(fit, mu) {
  shape <- as.vector(posterior::draws_of(fit$draws$bShape))
  .per_draw(mu, fit$data$weight_kg, function(y, mu_d, d) {
    extras::res_gamma(y, shape = shape[d], rate = shape[d] / exp(mu_d))
  })
}

#' @export
.deviance.kb_fit_size_nereo <- function(fit, mu) {
  shape <- as.vector(posterior::draws_of(fit$draws$bShape))
  .per_draw(mu, fit$data$diameter_mm, function(y, mu_d, d) {
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

#' @export
.deviance.kb_fit_density_nereo <- function(fit, mu) {
  theta <- as.vector(posterior::draws_of(fit$draws$bDispersion))
  zi <- 1 / (1 + exp(-as.vector(posterior::draws_of(fit$draws$bZeroInflation))))
  .per_draw(mu, fit$data$stipes, function(y, mu_d, d) {
    extras::res_gamma_pois_zi(y, exp(mu_d), theta[d], prob = zi[d])
  })
}

#' @export
.deviance.kb_fit_density_macro <- function(fit, mu) {
  theta <- as.vector(posterior::draws_of(fit$draws$bDispersion))
  .per_draw(mu, fit$data$plants, function(y, mu_d, d) {
    extras::res_gamma_pois(y, exp(mu_d), theta[d])
  })
}

#' @export
.deviance.kb_fit_wetdry <- function(fit, mu) {
  precision <- as.vector(posterior::draws_of(fit$draws$bPrecision))
  ratio <- fit$data$dry_mass_g / fit$data$wet_mass_g
  .per_draw(mu, ratio, function(y, mu_d, d) {
    m <- 1 / (1 + exp(-mu_d))
    res_beta(y, m * precision[d], (1 - m) * precision[d])
  })
}
