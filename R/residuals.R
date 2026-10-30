#' Deviance residuals
#'
#' Posterior point estimates of the deviance residual at each observed row, from
#' the fitted likelihood, matching [augment()]'s `residual` column.
#'
#' @details
#' The deviance residual is computed per draw, then summarised with the posterior
#' median. The likelihoods are Normal on log weight (*Nereocystis* weight),
#' Gamma on weight (*Macrocystis* weight), Weibull on diameter (*Nereocystis*
#' size), Beta on the dry:wet ratio (wet/dry) and the carbon and nitrogen
#' fractions (carbon, nitrogen), and Gamma on in situ survey biomass (cover
#' calibration). Where the cover calibration has a presence part, the residual
#' combines the Bernoulli and Gamma deviances and is signed by the difference
#' from the expected biomass.
#'
#'
#' @inheritParams params
#' @returns A numeric vector of deviance residuals, length `nobs(object)`.
#' @family fit methods
#' @seealso [fitted()] for fitted values, and [augment()].
#' @exportS3Method stats::residuals
#' @examples
#' residuals(fit_weight_sim_nereo)
residuals.kb_fit <- function(object, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(object)
  mu <- posterior::draws_of(.linpred_obs(object)) # link scale, D x N
  res <- .eval_family(object, mu, object$data, "res")
  as.numeric(apply(res, 2L, stats::median))
}
