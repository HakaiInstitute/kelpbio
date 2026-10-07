#' Prior Sensitivity of a Model Fit
#'
#' Assess how much each parameter's posterior depends on its prior and on the
#' data, by power-scaling (Kallioinen et al. 2024).
#'
#' @details
#' Power-scaling raises the prior, or the likelihood, to a power slightly above
#' and below 1 and measures how far each parameter's posterior moves, as a
#' cumulative Jensen-Shannon (CJS) distance. It uses the stored draws, so the
#' model is not refitted.
#'
#' Each parameter falls into one of four cases:
#'
#' - `weak_prior` and `strong_data`: the estimate is driven by the data, the
#'   desirable case.
#' - `strong_data` but not `weak_prior`: the prior and the data both move the
#'   estimate, a possible conflict between them. Check whether the prior is
#'   consistent with what the data show.
#' - neither: the prior dominates and the data say little about the parameter.
#'   The estimate reflects the prior, so the prior needs a justification.
#' - `weak_prior` but not `strong_data`: neither moves the estimate much, often a
#'   parameter the data identify only weakly.
#'
#' Each `term` is also the name of its prior's entry in the list from the
#' model's `kb_priors_*()` function, so to change a flagged prior, edit that
#' entry and refit. Random-effect levels are not
#' assessed; their standard deviations (`sd_site`, `sd_year`, `sd_site_year`) carry the
#' sensitivity of each random effect.
#'
#' Requires the priorsense package. Its functions, such as
#' `priorsense::powerscale_plot_dens()`, also accept a fit directly.
#'
#' @param fit A `kb_fit` object.
#' @param ... Unused.
#' @param prior_threshold A number greater than 0: a parameter with `prior_cjs`
#'   below it has a weak prior.
#' @param likelihood_threshold A number greater than 0: a parameter with
#'   `likelihood_cjs` at or above it has strong data.
#'
#' @return A tibble with one row per parameter that has a prior and columns
#'   `term` (the parameter, which is also its prior entry), `prior_cjs` and
#'   `likelihood_cjs` (the sensitivity to the prior and to the likelihood),
#'   `weak_prior`, and `strong_data`.
#' @references
#' Kallioinen, N., Paananen, T., Bürkner, P.-C., and Vehtari, A. (2024).
#' Detecting and diagnosing prior and likelihood sensitivity with power-scaling.
#' Statistics and Computing, 34, 57.
#' @family model
#' @export
#'
#' @examplesIf rlang::is_installed("priorsense")
#' kb_sensitivity(fit_weight_sim_nereo)
kb_sensitivity <- function(
  fit,
  ...,
  prior_threshold = 0.1,
  likelihood_threshold = 0.05
) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit)
  chk::chk_number(prior_threshold)
  chk::chk_gt(prior_threshold)
  chk::chk_number(likelihood_threshold)
  chk::chk_gt(likelihood_threshold)
  .chk_sensitivity_fit(fit)
  rlang::check_installed("priorsense", reason = "to assess prior sensitivity.")

  terms <- fit$meta$terms$fixed
  cjs <- priorsense::powerscale_sensitivity(fit)
  cjs <- cjs[match(terms, cjs$variable), ]
  tibble::tibble(
    term = terms,
    prior_cjs = cjs$prior,
    likelihood_cjs = cjs$likelihood,
    weak_prior = cjs$prior < prior_threshold,
    strong_data = cjs$likelihood >= likelihood_threshold
  )
}
