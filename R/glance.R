#' Model Fit Diagnostic Summary
#'
#' One-row summary of a model fit with convergence diagnostics.
#'
#' @inheritParams converged.kb_fit
#'
#' @section Output:
#'
#' There are three indicators of convergence in the output:
#'
#' - `rhat` is the potential scale reduction factor for the worst-performing
#'   parameter: a comparison of between- and within-chain variance, with values
#'   near 1 indicating convergence.
#' - `ess` is the bulk effective sample size for the worst-performing parameter:
#'   the number of independent draws after accounting for autocorrelation.
#' - `perc_divergent` is the divergent transition rate: the divergent
#'   transitions divided by the number of saved draws (i.e., post-thinning),
#'   expressed as a percentage.
#'
#' @inheritSection converged.kb_fit Assessing convergence
#' @inheritSection converged.kb_fit Resolving convergence failure
#' @seealso [converged()], which produces the `converged` column.
#'
#' @return A one-row tibble with `n`, `K`, `nchains`, `niters`, `nthin`, `ess`,
#'   `rhat`, `perc_divergent`, and `converged`.
#' @family generics
#' @exportS3Method generics::glance
#' @examples
#' glance(fit_weight_sim_nereo)
glance.kb_fit <- function(
  x,
  ...,
  rhat = 1.01,
  esr = 0.1,
  max_perc_divergent = 0.2
) {
  rlang::check_dots_empty()
  s <- x$diagnostics$summary
  # Evaluate the verdict before tibble(); inside it the bare `rhat` would mask
  # to the column, not the threshold arg.
  is_converged <- converged(
    x,
    rhat = rhat,
    esr = esr,
    max_perc_divergent = max_perc_divergent
  )
  tibble::tibble(
    n = nobs(x),
    K = npars(x),
    nchains = nchains(x),
    niters = niters(x),
    nthin = x$meta$nthin,
    # min()/max() on an all-NA vector return Inf/-Inf with a base warning.
    ess = if (any(is.finite(s$ess_bulk))) {
      min(s$ess_bulk, na.rm = TRUE)
    } else {
      NA_real_
    },
    rhat = if (any(is.finite(s$rhat))) max(s$rhat, na.rm = TRUE) else NA_real_,
    perc_divergent = x$diagnostics$perc_divergent,
    converged = is_converged
  )
}
