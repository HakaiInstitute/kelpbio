#' Prior sensitivity
#'
#' Assess how much each parameter's posterior depends on its prior and on the
#' data, by power-scaling (Kallioinen et al. 2024).
#'
#' @details
#' A parameter is driven by the data when it has both `weak_prior` and
#' `strong_data`; see the
#' [Advanced article](https://hakaiinstitute.github.io/kelpbio/articles/advanced.html#prior-sensitivity)
#' for the other cases. The cover calibration's `tide_height_slope` has an
#' informative prior by design, so `informative_prior` marks it.
#' Requires the priorsense package.
#'
#' @inheritParams params
#' @param prior_threshold A number greater than 0: a parameter with `prior_cjs`
#'   below it has a weak prior.
#' @param likelihood_threshold A number greater than 0: a parameter with
#'   `likelihood_cjs` at or above it has strong data.
#'
#' @returns A tibble with one row per parameter that has a prior and columns
#'   `term` (the parameter, which is also its prior entry), `prior_cjs` and
#'   `likelihood_cjs` (the sensitivity to the prior and to the likelihood),
#'   `weak_prior`, `strong_data`, and `informative_prior` (whether the prior is
#'   informative by design).
#' @references
#' Kallioinen, N., Paananen, T., Bürkner, P.-C., and Vehtari, A. (2024).
#' Detecting and diagnosing prior and likelihood sensitivity with power-scaling.
#' Statistics and Computing, 34, 57.
#' @family diagnostics
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
  .chk_likelihood_fit(fit, "its prior sensitivity cannot be assessed")
  rlang::check_installed("priorsense", reason = "to assess prior sensitivity.")

  terms <- fit$meta$terms$fixed
  cjs <- priorsense::powerscale_sensitivity(fit)
  cjs <- cjs[match(terms, cjs$variable), ]
  tibble::tibble(
    term = terms,
    prior_cjs = cjs$prior,
    likelihood_cjs = cjs$likelihood,
    weak_prior = cjs$prior < prior_threshold,
    strong_data = cjs$likelihood >= likelihood_threshold,
    informative_prior = terms %in% fit$meta$informative_priors
  )
}
