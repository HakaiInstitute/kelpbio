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
tidy.kb_fit_weight <- function(
  x,
  ...,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3,
  include_random_effects = FALSE
) {
  rlang::check_dots_empty()
  .chk_kb_fit_weight(x)
  .chk_summary_args(conf_level, estimate, sig_fig)
  chk::chk_flag(include_random_effects)

  summarise_draws_terms(
    x$draws,
    variables = .weight_terms(x, include_random_effects),
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig
  )
}

# The model terms to summarise, named explicitly because parameter shape doesn't
# identify a term's role; species-specific, so it dispatches on the fit subclass.
.weight_terms <- function(x, include_random_effects) {
  UseMethod(".weight_terms")
}

.weight_terms.kb_fit_weight_nereo <- function(x, include_random_effects) {
  variables <- c(
    "bWeight",
    "bDiameter",
    "bDiameter2",
    "sSite",
    "sSiteDiameter",
    "sSiteYear",
    "sWeight"
  )
  if (include_random_effects) {
    variables <- c(variables, "bSite", "bSiteDiameter", "bSiteYear")
  }
  variables
}

.weight_terms.kb_fit_weight_macro <- function(x, include_random_effects) {
  variables <- c("bWeight", "bFronds", "shape", "sSite", "sYear", "sSiteYear")
  if (include_random_effects) {
    variables <- c(variables, "bSite", "bYear", "bSiteYear")
  }
  variables
}
