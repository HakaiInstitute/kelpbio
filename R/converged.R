#' Convergence of a Model Fit
#'
#' Whether a model fit has converged, from the Rhat and bulk effective sample
#' rate of its parameters.
#'
#' @inheritParams params
#' @param x A `kb_fit` object.
#' @param ... Unused.
#'
#' @details
#' `esr` is the effective sample rate: the bulk effective sample size divided by
#' the number of draws. Convergence is assessed on the bulk effective sample size
#' only, not the tail. The defaults are `rhat = 1.05` and `esr = 0.1`.
#'
#' @return A flag: `TRUE` if all Rhat are below `rhat` and all bulk effective
#'   sample rates above `esr`.
#' @family generics
#' @exportS3Method universals::converged
#' @examples
#' converged(fit_weight_sim_nereo)
converged.kb_fit <- function(x, ..., rhat = 1.05, esr = 0.1) {
  rlang::check_dots_empty()
  chk::chk_number(rhat)
  chk::chk_number(esr)
  s <- x$diagnostics$summary
  ndraws <- posterior::ndraws(x$draws)
  all(s$rhat < rhat, na.rm = TRUE) &&
    all((s$ess_bulk / ndraws) > esr, na.rm = TRUE)
}
