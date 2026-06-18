#' Convergence of a Model Fit
#'
#' @inheritParams params
#' @param x A `kb_fit` object.
#' @param rhat A number: the maximum acceptable Rhat.
#' @param ess A number: the minimum acceptable bulk effective sample size.
#' @param ... Unused.
#'
#' @return A flag: `TRUE` if all Rhat are below `rhat` and all bulk ESS above
#'   `ess`.
#' @exportS3Method universals::converged
converged.kb_fit <- function(x, rhat = 1.05, ess = 400, ...) {
  rlang::check_dots_empty()
  chk::chk_number(rhat)
  chk::chk_number(ess)
  s <- x$diagnostics$summary
  all(s$rhat < rhat, na.rm = TRUE) && all(s$ess_bulk > ess, na.rm = TRUE)
}
