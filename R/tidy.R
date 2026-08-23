#' Tidy a Model Fit
#'
#' Posterior summaries of the model terms: the population-level effects and the
#' random-effect standard deviations, plus (when `include_random_effects = TRUE`)
#' the group-level deviations. By default the per-level deviations are omitted,
#' following the `broom.mixed` convention.
#'
#' @inheritParams params
#' @param x A `kb_fit` object.
#' @param ... Unused.
#'
#' @return A tibble with one row per term and columns `term`, `estimate`,
#'   `lower`, `upper`.
#' @family generics
#' @exportS3Method generics::tidy
#' @examples
#' tidy(fit_weight_sim_nereo)
tidy.kb_fit <- function(
  x,
  ...,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3,
  include_random_effects = FALSE
) {
  rlang::check_dots_empty()
  .chk_kb_fit(x)
  .chk_summary_args(conf_level, estimate, sig_fig)
  chk::chk_flag(include_random_effects)

  summarise_draws_terms(
    x$draws,
    variables = .terms(x, include_random_effects),
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig
  )
}

# pull our model-specific terms set at fit time
.terms <- function(fit, include_random_effects) {
  terms <- fit$meta$terms
  if (include_random_effects) c(terms$fixed, terms$random) else terms$fixed
}
