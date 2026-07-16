#' Glance at a Model Fit
#'
#' One-row summary of a model fit with a convergence verdict.
#'
#' @inheritParams converged.kb_fit
#'
#' @return A one-row tibble with `n`, `K`, `nchains`, `niters`, `nthin`, `ess`
#'   (the minimum bulk effective sample size), `rhat` (the maximum Rhat), and
#'   `converged`.
#' @family generics
#' @exportS3Method generics::glance
#' @examples
#' glance(fit_weight_sim_nereo)
glance.kb_fit <- function(x, ..., rhat = 1.05, esr = 0.1) {
  rlang::check_dots_empty()
  s <- x$diagnostics$summary
  # Evaluate the verdict before tibble(); inside it the bare `rhat` would mask
  # to the column, not the threshold arg.
  is_converged <- converged(x, rhat = rhat, esr = esr)
  tibble::tibble(
    n = nobs(x),
    K = npars(x),
    nchains = nchains(x),
    niters = niters(x),
    nthin = x$meta$nthin,
    ess = min(s$ess_bulk, na.rm = TRUE),
    rhat = max(s$rhat, na.rm = TRUE),
    converged = is_converged
  )
}
