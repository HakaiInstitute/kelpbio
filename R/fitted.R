#' Fitted Weights
#'
#' Posterior point estimates of the expected weight at each observed row, on the
#' response scale (the posterior median of the expected weight, equivalently
#' [posterior_epred()] summarised). Returned as a numeric vector, one value per
#' row, matching [augment()]'s `fitted` column.
#'
#' @param object A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return A numeric vector of fitted weights, length `nobs(object)`.
#' @family generics
#' @seealso [residuals()] for deviance residuals, and [augment()].
#' @exportS3Method stats::fitted
#' @examples
#' fitted(fit_weight_hakai_nereo)
fitted.kb_fit_weight <- function(object, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit_weight(object)
  as.numeric(stats::median(exp(.weight_nereo_linpred_obs(object))))
}
