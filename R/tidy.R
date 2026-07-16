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
#' tidy(fit_weight_sim_nereo)
tidy.kb_fit_weight <- function(x,
                               ...,
                               conf_level = 0.95,
                               estimate = stats::median,
                               sig_fig = 3,
                               include_random_effects = FALSE) {
  rlang::check_dots_empty()
  .chk_kb_fit_weight(x)
  .chk_summary_args(conf_level, estimate, sig_fig)
  chk::chk_flag(include_random_effects)

  # Terms are named explicitly rather than inferred from parameter shape: a
  # scalar can be a population effect, an SD, or a single-level random effect,
  # and a fixed effect can be vector-valued, so shape does not identify the role.
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
