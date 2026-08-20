#' Convergence of a Model Fit
#'
#' Whether a model fit has converged, from the Rhat, bulk effective sample rate,
#' and rate of divergent transitions.
#'
#' @inheritParams params
#' @param x A `kb_fit` object.
#' @param ... Unused.
#'
#' @section Assessing convergence:
#'
#' Three conditions must be met:
#'
#' - every parameter's Rhat below `rhat` (default 1.01)
#' - every parameter's effective sample rate (bulk effective sample size divided by the number of
#'   saved draws) above `esr` (default 0.1)
#' - the divergence rate at or below `max_perc_divergent` (default 0.2)
#'
#' Divergent transitions indicate that the sampler failed to explore part of
#' the posterior, and the draws may be biased regardless of whether other
#' convergence metrics pass.
#'
#' Treedepth saturation and E-BFMI are additionally reported in
#' `print(summary(x))`, although these do not affect convergence. The former
#' indicates issues with efficiency and the latter is a per-chain signal that in
#' practice accompanies divergences.
#'
#' @section Resolving convergence failure:
#'
#' In order, try the following:
#' 1. Increase `adapt_delta` through the `control` argument of the `kb_fit_*()`
#'    functions (e.g., `kb_fit_*(df, control = list(adapt_delta = 0.99))`). The
#'    default `adapt_delta` value is 0.95. Higher `adapt_delta` values will
#'    increase model runtime. This should reduce divergent transitions and can
#'    also resolve rhat/ess issues.
#' 2. Increase the thinning rate (e.g., `kb_fit_*(df, nthin = 5)`). This
#'    increases the total number of iterations, while saving only 1/`nthin`,
#'    which increases the total information.
#' 3. Tighten the SD priors.
#'
#' @return A flag: `TRUE` if all Rhat are below `rhat`, all bulk effective
#'   sample rates above `esr`, and the divergence rate at or below
#'   `max_perc_divergent`.
#' @family generics
#' @exportS3Method universals::converged
#' @examples
#' converged(fit_weight_sim_nereo)
#'
#' # Require no divergent transitions at all:
#' converged(fit_weight_sim_nereo, max_perc_divergent = 0)
converged.kb_fit <- function(
  x,
  ...,
  rhat = 1.01,
  esr = 0.1,
  max_perc_divergent = 0.2
) {
  rlang::check_dots_empty()
  chk::chk_number(rhat)
  chk::chk_number(esr)
  chk::chk_number(max_perc_divergent)
  chk::chk_gte(max_perc_divergent, value = 0)
  s <- x$diagnostics$summary
  ndraws <- posterior::ndraws(x$draws)
  # An all-NA Rhat would make all(na.rm = TRUE) pass on no evidence, so require
  # at least one finite value. Individual NAs are still skipped, since a
  # legitimately constant parameter must not fail the fit.
  any(is.finite(s$rhat)) &&
    all(s$rhat < rhat, na.rm = TRUE) &&
    all((s$ess_bulk / ndraws) > esr, na.rm = TRUE) &&
    isTRUE(x$diagnostics$perc_divergent <= max_perc_divergent)
}
