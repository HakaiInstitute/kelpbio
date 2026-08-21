#' Fitted Values
#'
#' Posterior point estimates (median) of the response-scale value at each observed
#' row, matching [augment()]'s `fitted` column. For the full posterior, use
#' [posterior_epred()].
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
