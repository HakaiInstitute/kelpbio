#' Deviance residuals
#'
#' Posterior point estimates of the deviance residual at each observed row, from
#' the fitted likelihood, matching [augment()]'s `residual` column.
#'
#' @details
#' The deviance residual is computed per draw, then summarised with the posterior
#' median, from the likelihood of the fit's model (see [kb_model_describe()]).
#' Where the cover calibration has a presence part, the residual combines the
#' deviances of plant presence and biomass and is signed by the difference
#' from the expected biomass.
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
