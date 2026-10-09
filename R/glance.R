#' Model Fit Diagnostic Summary
#'
#' One-row summary of a model fit with convergence diagnostics.
#'
#' @inheritParams kb_converged
#' @param x A `kb_fit` object.
#'
#' @section Output:
#'
#' There are three indicators of convergence in the output:
#'
#' - `rhat` is the potential scale reduction factor for the worst-performing
#'   parameter: a comparison of between- and within-chain variance, with values
#'   near 1 indicating convergence.
#' - `ess_bulk` and `ess_tail` are the bulk and tail effective sample sizes for
#'   the worst-performing parameter: the number of independent draws worth of
#'   information about the centre and the tails of its posterior.
#' - `perc_divergent` is the divergent transition rate: the divergent
#'   transitions divided by the number of saved draws (i.e., post-thinning),
#'   expressed as a percentage.
#'
#' @inheritSection kb_converged Assessing convergence
#' @inheritSection kb_converged Resolving convergence failure
#' @seealso [kb_converged()], which produces the `converged` column.
#'
#' @return A one-row tibble with `n`, `K`, `nchains`, `niters`, `nthin`,
#'   `ess_bulk`, `ess_tail`, `rhat`, `perc_divergent`, and `converged`.
#' @family generics
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
    K = posterior::nvariables(x$draws),
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
