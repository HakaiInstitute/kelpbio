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
#' negative binomial on plant count (*Macrocystis* density), Beta on the
#' dry:wet mass ratio (wet/dry) and the carbon fraction (carbon), and Normal on
#' the log in situ biomass estimate (cover).
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
  res <- .eval_family(object, mu, object$data, "res")
  as.numeric(apply(res, 2L, stats::median))
}
