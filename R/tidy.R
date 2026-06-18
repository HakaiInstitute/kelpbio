#' Tidy a Weight Model Fit
#'
#' Posterior summaries of the population-level terms and random-effect standard
#' deviations.
#'
#' @inheritParams params
#' @param x A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return A tibble with one row per term and columns `term`, `estimate`,
#'   `std.error`, `conf.low`, `conf.high`.
#' @exportS3Method generics::tidy
tidy.kb_fit_weight <- function(x, conf_level = 0.95, ...) {
  rlang::check_dots_empty()
  chk::chk_number(conf_level)
  chk::chk_range(conf_level)
  summarise_draws_terms(
    x$draws,
    variables = c(
      "bWeight30", "bDiameter", "bDiameter2",
      "sSite", "sSiteDiameter", "sSiteYear", "sWeight"
    ),
    conf_level = conf_level
  )
}
