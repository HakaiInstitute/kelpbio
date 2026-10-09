#' Fitted Values
#'
#' Posterior medians of the expected response at each observed row, matching
#' [augment()]'s `fitted` column: wet weight (kg) for weight fits, sub-bulb
#' diameter (mm) or fronds for size fits, the stipe or plant count on the
#' transect for density fits, the dry:wet ratio for wet/dry fits, the carbon
#' fraction of dry mass for carbon fits, and wet biomass (kg/m²) for cover
#' biomass fits. For the full posterior, use [posterior_epred()].
#'
#' @param object A `kb_fit` object.
#' @param ... Unused.
#'
#' @return A numeric vector of fitted values on the response scale, length
#'   `nobs(object)`.
#' @family generics
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
