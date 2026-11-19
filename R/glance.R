#' One-row summary of a fit
#'
#' One-row summary of a model fit with convergence diagnostics.
#'
#' @inheritParams params
#' @inheritParams kb_converged
#'
#' @seealso [kb_converged()] for the convergence thresholds and what to do
#'   when they fail.
#'
#' @returns A one-row tibble with `n` (the number of observations), `K` (the
#'   number of terms [tidy()] reports, excluding the per-level group effects),
#'   `nchains`, `niters`, `nthin`, the worst `ess_bulk`, `ess_tail`, and `rhat`
#'   across parameters, `perc_divergent` (the percentage of saved draws that
#'   ended in a divergent transition), and `converged` (from [kb_converged()]).
#' @family fit methods
#' @exportS3Method generics::glance
#' @examples
#' glance(fit_weight_sim_nereo)
glance.kb_fit <- function(
  x,
  ...,
  rhat = 1.01,
  ess = 100,
  max_perc_divergent = 0.2
) {
  # Outside tibble(), where `rhat` would resolve to the column.
  is_converged <- .with_call(
    {
      rlang::check_dots_empty()
      kb_converged(
        x,
        rhat = rhat,
        ess = ess,
        max_perc_divergent = max_perc_divergent
      )
    },
    # error_call() names the generic, not the method.
    rlang::error_call(rlang::current_env())
  )
  s <- x$diagnostics$summary
  tibble::tibble(
    n = nobs(x),
    K = length(x$meta$terms$fixed),
    nchains = posterior::nchains(x$draws),
    niters = posterior::niterations(x$draws),
    nthin = x$meta$nthin,
    ess_bulk = .min_finite(s$ess_bulk),
    ess_tail = .min_finite(s$ess_tail),
    rhat = if (any(is.finite(s$rhat))) max(s$rhat, na.rm = TRUE) else NA_real_,
    perc_divergent = x$diagnostics$perc_divergent,
    converged = is_converged
  )
}

# min() on an all-NA vector returns Inf with a base warning.
.min_finite <- function(x) {
  if (any(is.finite(x))) min(x, na.rm = TRUE) else NA_real_
}
