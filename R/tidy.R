#' Tidy a Weight Model Fit
#'
#' Posterior summaries of the model terms: the population-level effects and the
#' random-effect standard deviations, plus (when `include_random_effects = TRUE`)
#' the group-level deviations. By default the per-level deviations are omitted,
#' following the `broom.mixed` convention.
#'
#' @inheritParams params
#' @param x A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return A tibble with one row per term and columns `term`, `estimate`,
#'   `lower`, `upper`.
#' @family generics
#' @exportS3Method generics::tidy
#' @examples
#' tidy(fit_weight_hakai_nereo)
tidy.kb_fit_weight <- function(x,
                               conf_level = 0.95,
                               estimate = stats::median,
                               sig_fig = 3,
                               include_random_effects = FALSE,
                               ...) {
  rlang::check_dots_empty()
  .chk_kb_fit_weight(x)
  chk::chk_number(conf_level)
  chk::chk_range(conf_level)
  chk::chk_function(estimate)
  chk::chk_whole_number(sig_fig)
  chk::chk_gt(sig_fig, value = 0)
  chk::chk_flag(include_random_effects)

  variables <- c(
    "bWeight", "bDiameter", "bDiameter2",
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
