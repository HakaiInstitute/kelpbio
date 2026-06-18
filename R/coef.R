#' Group-Level Coefficients of a Weight Model Fit
#'
#' Posterior summaries of the group-level random effects: the per-site intercept
#' and slope, and the site-year effects.
#'
#' @inheritParams params
#' @param object A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return A tibble with one row per group-level term and columns `term`,
#'   `estimate`, `std.error`, `conf.low`, `conf.high`.
#' @exportS3Method stats::coef
coef.kb_fit_weight <- function(object, conf_level = 0.95, ...) {
  rlang::check_dots_empty()
  chk::chk_number(conf_level)
  chk::chk_range(conf_level)
  summarise_draws_terms(
    object$draws,
    variables = c("bSite", "bSiteDiameter", "bSiteYear"),
    conf_level = conf_level
  )
}
