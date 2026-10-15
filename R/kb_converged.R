#' Convergence of a Model Fit
#'
#' Whether a model fit has converged, from the Rhat and effective sample sizes
#' of its parameters and its rate of divergent transitions.
#'
#' @inheritParams params
#' @param fit A `kb_fit` object.
#' @param ... Unused.
#'
#' @section Assessing convergence:
#'
#' Three conditions must be met:
#'
#' - every parameter's rank-normalized split Rhat below `rhat` (default 1.01;
#'   Vehtari et al. 2021, Section 2);
#' - every parameter's bulk and tail effective sample size at least `ess` times
#'   the number of chains (default 100, so 400 for four chains; Vehtari et al.
#'   2021);
#' - the percentage of divergent transitions at or below `max_perc_divergent`
#'   (default 0.2% of saved draws). Set `max_perc_divergent = 0` to require
#'   none.
#'
#' Rhat and the effective sample sizes are those of [posterior::rhat()],
#' [posterior::ess_bulk()], and [posterior::ess_tail()], reported for each
#' parameter by `posterior::summarise_draws(fit)`.
#'
#' @section Resolving convergence failure:
#'
#' In order, try the following:
#' 1. Increase `adapt_delta` through the `control` argument of the `kb_fit_*()`
#'    functions (e.g., `kb_fit_*(df, control = list(adapt_delta = 0.99))`). The
#'    default `adapt_delta` value is 0.95. Higher values reduce divergent
#'    transitions and can also resolve Rhat and effective sample size issues,
#'    at the cost of a longer runtime.
#' 2. Run longer: increase `niters`, or `nthin` to run more iterations while
#'    saving the same number of draws. Both raise the effective sample sizes.
#' 3. Narrow the priors on the random-effect standard deviations (`sd_site`,
#'    `sd_year`, `sd_site_year`) through the `priors` argument.
#'
#' @references
#' Vehtari, A., Gelman, A., Simpson, D., Carpenter, B., and Bürkner, P.-C.
#' (2021). Rank-normalization, folding, and localization: An improved
#' \eqn{\widehat{R}}{R-hat} for assessing convergence of MCMC. *Bayesian
#' Analysis*, 16(2), 667-718. \doi{10.1214/20-BA1221}
#'
#' Stan Development Team. Runtime warnings and convergence problems.
#' <https://mc-stan.org/learn-stan/diagnostics-warnings.html>
#'
#' @return A flag: `TRUE` if all three conditions are met, otherwise `FALSE`.
#' @family model
#' @export
#' @examples
#' kb_converged(fit_weight_sim_nereo)
#'
#' # Require no divergent transitions at all:
#' kb_converged(fit_weight_sim_nereo, max_perc_divergent = 0)
kb_converged <- function(
  fit,
  ...,
  rhat = 1.01,
  ess = 100,
  max_perc_divergent = 0.2
) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit)
  chk::chk_number(rhat)
  chk::chk_number(ess)
  chk::chk_gte(ess, value = 0)
  chk::chk_number(max_perc_divergent)
  chk::chk_gte(max_perc_divergent, value = 0)
  s <- fit$diagnostics$summary
  min_ess <- ess * posterior::nchains(fit$draws)
  # An all-NA Rhat must not pass vacuously; single NAs (constant parameters)
  # are skipped.
  any(is.finite(s$rhat)) &&
    all(s$rhat < rhat, na.rm = TRUE) &&
    all(s$ess_bulk >= min_ess, na.rm = TRUE) &&
    all(s$ess_tail >= min_ess, na.rm = TRUE) &&
    isTRUE(fit$diagnostics$perc_divergent <= max_perc_divergent)
}
