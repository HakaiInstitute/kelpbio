#' Influential observations
#'
#' Identify the observations that most influence a fit and those it predicts
#' poorly, by Pareto-smoothed importance-sampling leave-one-out cross-validation
#' (PSIS-LOO; Vehtari et al. 2017).
#'
#' @details
#' `pareto_k` measures how much the fit changes when an observation is left
#' out, and `elpd_loo` how well the observation is predicted by a fit without
#' it; see the
#' [Advanced article](https://hakaiinstitute.github.io/kelpbio/articles/advanced.html#influential-observations)
#' for details.
#'
#' @inheritParams params
#' @param threshold A number greater than 0: an observation with `pareto_k`
#'   above it is influential. `NULL` (the default) uses the threshold of
#'   [loo::loo()], `min(1 - 1 / log10(S), 0.7)` for `S` posterior draws.
#'
#' @returns The fitted data as a tibble, one row per observation, with added
#'   columns `elpd_loo`, `pareto_k`, and `influential`.
#' @references
#' Vehtari, A., Gelman, A., and Gabry, J. (2017). Practical Bayesian model
#' evaluation using leave-one-out cross-validation and WAIC. Statistics and
#' Computing, 27, 1413-1432.
#' @family diagnostics
#' @seealso [loo.kb_fit()] for the full PSIS-LOO result.
#' @export
#'
#' @examples
#' influence <- kb_influence(fit_weight_sim_nereo)
#' influence[influence$influential, ]
kb_influence <- function(fit, ..., threshold = NULL) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit)
  if (!is.null(threshold)) {
    chk::chk_number(threshold)
    chk::chk_gt(threshold)
  }
  .chk_likelihood_fit(fit, "it cannot be cross-validated")
  # loo's sample-size-dependent threshold, which loo does not export.
  threshold <- threshold %||%
    min(1 - 1 / log10(posterior::ndraws(fit$draws)), 0.7)

  # The influential column reports high Pareto k, so loo's warning is redundant.
  psis <- withCallingHandlers(
    loo(fit),
    warning = function(w) {
      if (grepl("Pareto k", conditionMessage(w), fixed = TRUE)) {
        invokeRestart("muffleWarning")
      }
    }
  )
  out <- tibble::as_tibble(fit$data)
  out$elpd_loo <- psis$pointwise[, "elpd_loo"]
  out$pareto_k <- loo::pareto_k_values(psis)
  out$influential <- out$pareto_k > threshold
  out
}
