#' Convergence of a Model Fit
#'
#' @inheritParams params
#' @param x A `kb_fit` object.
#' @param ... Unused.
#'
#' @details
#' The thresholds default to the `report` analysis-mode values (`rhat = 1.05`,
#' `esr = 0.1`). `esr` is the effective sample rate (effective sample size
#' divided by the number of draws); a rate is used rather than an absolute ESS
#' because it is stable under changes to the number of saved iterations.
#'
#' @return A flag: `TRUE` if all Rhat are below `rhat` and all effective sample
#'   rates above `esr`.
#' @exportS3Method universals::converged
converged.kb_fit <- function(x, rhat = 1.05, esr = 0.1, ...) {
  rlang::check_dots_empty()
  chk::chk_number(rhat)
  chk::chk_number(esr)
  s <- x$diagnostics$summary
  ndraws <- posterior::ndraws(x$draws)
  all(s$rhat < rhat, na.rm = TRUE) &&
    all((s$ess_bulk / ndraws) > esr, na.rm = TRUE)
}
