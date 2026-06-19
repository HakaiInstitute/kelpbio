#' Glance at a Model Fit
#'
#' One-row summary of a model fit with convergence verdict, using the
#' `bboutools` column set.
#'
#' @inheritParams converged.kb_fit
#'
#' @return A one-row tibble with `n`, `K`, `nchains`, `niters`, `nthin`, `ess`,
#'   `rhat`, and `converged`.
#' @exportS3Method generics::glance
glance.kb_fit <- function(x, rhat = 1.05, esr = 0.1, ...) {
  rlang::check_dots_empty()
  s <- x$diagnostics$summary
  tibble::tibble(
    n = nobs(x),
    K = npars(x),
    nchains = nchains(x),
    niters = niters(x),
    nthin = x$meta$nthin,
    ess = min(s$ess_bulk, na.rm = TRUE),
    rhat = max(s$rhat, na.rm = TRUE),
    converged = converged(x, rhat = rhat, esr = esr)
  )
}
