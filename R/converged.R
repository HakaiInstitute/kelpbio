#' Convergence of a Model Fit
#'
#' Whether a model fit has converged, from the Rhat, bulk effective sample rate,
#' and divergent-transition rate of its parameters.
#'
#' @inheritParams params
#' @param x A `kb_fit` object.
#' @param ... Unused.
#'
#' @details
#' All three conditions must hold: every Rhat below `rhat`, every bulk effective
#' sample rate above `esr`, and the divergence rate at or below
#' `max_perc_divergent`.
#' The defaults are `rhat = 1.01`, `esr = 0.1`, and `max_perc_divergent = 0.2`.
#' Set `max_perc_divergent = 0` to require a fit with no divergent transitions.
#'
#' `esr` is the effective sample rate: the bulk effective sample size divided by
#' the number of draws. Convergence is assessed on the bulk effective sample size
#' only, not the tail.
#'
#' Divergent transitions enter the verdict because they mean the sampler failed to
#' explore part of the posterior, so the draws may be biased whatever Rhat and the
#' effective sample size report. Treedepth saturation and E-BFMI do not: the first
#' affects efficiency rather than validity, and the second is a per-chain signal
#' that in practice accompanies divergences. Both are reported by
#' `print(summary(x))`. Raising `adapt_delta` through the `control` argument of the
#' `kb_fit_*()` functions often clears divergences.
#'
#' The divergence rate is a percentage of the saved draws, so with `nthin > 1` it
#' covers the retained draws only.
#'
#' @return A flag: `TRUE` if all Rhat are below `rhat`, all bulk effective sample
#'   rates above `esr`, and the divergence rate at or below `max_perc_divergent`.
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
