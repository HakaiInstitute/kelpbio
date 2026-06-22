#' Fitted Weights
#'
#' Posterior summary of the expected weight at each observed row, on the response
#' scale: the point estimate with a compatibility interval, one row per observed
#' row.
#'
#' @details
#' The expected weight is [posterior_epred()] at the observed data; the `estimate`
#' is its posterior point estimate and `lower`/`upper` its equal-tailed
#' `conf_level` limits.
#'
#' @inheritParams params
#' @param object A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return A tibble with one row per observed row and columns `estimate`,
#'   `lower`, and `upper`.
#' @family generics
#' @seealso [residuals()] for deviance residuals, and [augment()].
#' @exportS3Method stats::fitted
#' @examples
#' fitted(fit_weight_hakai_nereo)
fitted.kb_fit_weight <- function(object, conf_level = 0.95,
                                 estimate = stats::median, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit_weight(object)
  chk::chk_number(conf_level)
  chk::chk_range(conf_level)
  chk::chk_function(estimate)
  summarise_rvar(exp(.weight_nereo_linpred_obs(object)), conf_level, estimate)
}
