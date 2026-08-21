#' Tidy a Weight Model Fit
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

# The parameter names to summarise, named explicitly because a parameter's shape
# does not identify its role. A random effect the fit dropped is omitted: its
# draws never met the likelihood, so reporting them would present the prior as an
# estimate.
.terms <- function(fit, include_random_effects) {
  UseMethod(".terms")
}

#' @export
.terms.default <- function(fit, include_random_effects) {
  .abort_no_method(x = fit, call = NULL)
}

#' @export
.terms.kb_fit_weight_nereo <- function(fit, include_random_effects) {
  site_year <- .site_year_on(fit)
  variables <- c(
    "bWeight",
    "bDiameter",
    "bDiameter2",
    "sSite",
    "sSiteDiameter",
    if (site_year) "sSiteYear",
    "sWeight"
  )
  if (include_random_effects) {
    variables <- c(
      variables,
      "bSite",
      "bSiteDiameter",
      if (site_year) "bSiteYear"
    )
  }
  variables
}

#' @export
.terms.kb_fit_weight_macro <- function(fit, include_random_effects) {
  site_year <- .site_year_on(fit)
  variables <- c(
    "bWeight",
    "bFronds",
    "shape",
    "sSite",
    "sYear",
    if (site_year) "sSiteYear"
  )
  if (include_random_effects) {
    variables <- c(variables, "bSite", "bYear", if (site_year) "bSiteYear")
  }
  variables
}
