#' Fitted values
#'
#' Posterior medians of the expected response at each observed row, matching
#' [augment()]'s `fitted` column: wet weight (kg) for weight fits, plant
#' diameter (mm) for size fits, the dry:wet ratio for wet/dry fits, the carbon
#' fraction of dry mass for carbon fits, and wet biomass (kg/m²) for cover
#' calibration fits. For the full posterior, use [posterior_epred()].
#'
#'
#' @inheritParams params
#' @returns A numeric vector of fitted values on the response scale, length
#'   `nobs(object)`.
#' @family fit methods
#' @seealso [residuals()] for deviance residuals, [augment()], and
#'   [posterior_epred()] for the full posterior.
#' @exportS3Method stats::fitted
#' @examples
#' fitted(fit_weight_sim_nereo)
fitted.kb_fit <- function(object, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(object)
  as.numeric(stats::median(.epred(object, .linpred_obs(object))))
}
