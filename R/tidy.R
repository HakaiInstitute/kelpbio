#' Tidy a Weight Model Fit
#'
#' Posterior summaries of the model terms: the population-level effects, the
#' random-effect standard deviations, and (when `include_random_effects = TRUE`)
#' the group-level random effects.
#'
#' @inheritParams params
#' @param x A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return A tibble with one row per term and columns `term`, `estimate`,
#'   `lower`, `upper`.
#' @exportS3Method generics::tidy
tidy.kb_fit_weight <- function(x,
                               conf_level = 0.95,
                               estimate = stats::median,
                               sig_fig = 3,
                               include_random_effects = TRUE,
                               ...) {
  rlang::check_dots_empty()
  chk::chk_number(conf_level)
  chk::chk_range(conf_level)
  chk::chk_function(estimate)
  chk::chk_whole_number(sig_fig)
  chk::chk_flag(include_random_effects)

  variables <- c(
    "bWeight30", "bDiameter", "bDiameter2",
    "sSite", "sSiteDiameter", "sSiteYear", "sWeight"
  )
  if (include_random_effects) {
    variables <- c(variables, "bSite", "bSiteDiameter", "bSiteYear")
  }
  summarise_draws_terms(
    x$draws,
    variables = variables,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig
  )
}
