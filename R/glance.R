#' Glance at a Model Fit
#'
#' One-row summary of a model fit with convergence verdict.
#'
#' @inheritParams converged.kb_fit
#'
#' @return A one-row tibble with `nobs`, `nchains`, `niters`, `npars`, and
#'   `converged`.
#' @exportS3Method generics::glance
glance.kb_fit <- function(x, rhat = 1.05, ess = 400, ...) {
  rlang::check_dots_empty()
  tibble::tibble(
    nobs = nobs(x),
    nchains = nchains(x),
    niters = niters(x),
    npars = npars(x),
    converged = converged(x, rhat = rhat, ess = ess)
  )
}
