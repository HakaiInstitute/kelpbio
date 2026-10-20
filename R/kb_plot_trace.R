#' Trace plot
#'
#' Plot the posterior draws of each term against iteration, one panel per term
#' and one line per chain, to check that the chains have mixed.
#'
#' @details
#' The terms are those [tidy()] reports: the population-level coefficients and
#' the random-effect standard deviations. Chains that have mixed overlap and
#' wander around a common level with no trend; a chain stuck apart from the
#' others, or a slow drift, points to a convergence problem that [kb_converged()]
#' and the `converged` column of [summary()][summary.kb_fit()] also report.
#'
#' @inheritParams params
#'
#' @returns A `ggplot` object from [bayesplot::mcmc_trace()].
#' @family diagnostics
#' @export
#' @examples
#' kb_plot_trace(fit_weight_sim_nereo)
kb_plot_trace <- function(fit, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit)
  draws <- posterior::subset_draws(
    fit$draws,
    variable = .terms(fit, include_random_effects = FALSE)
  )
  bayesplot::mcmc_trace(posterior::as_draws_array(draws))
}
