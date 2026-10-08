#' Leave-One-Out Cross-Validation
#'
#' Estimate how well a fit predicts each observation when that observation is
#' left out, by Pareto-smoothed importance-sampling leave-one-out
#' cross-validation (PSIS-LOO; Vehtari et al. 2017).
#'
#' @details
#' Computed from the stored draws and [log_lik()], so the model is not refitted.
#'
#' The pointwise results (`$pointwise` and `loo::pareto_k_values()`) have one row
#' per observation, in the order of the fitted data:
#'
#' - `elpd_loo` is the log density of the observation under a fit that left it
#'   out. A low value marks an observation the model predicts poorly, such as an
#'   outlier or a data error.
#' - The Pareto k diagnostic measures how much the fit changes when the
#'   observation is left out. A value above about 0.7 (the printed result gives
#'   the exact threshold, which depends on the number of draws) marks an
#'   influential observation, for which the PSIS-LOO estimate is also
#'   unreliable.
#'
#' The log-likelihood is of the response as recorded, so [loo::loo_compare()] can
#' compare fits to the same data, such as two forms of a model. It lists the
#' fits from best to worst predictive accuracy: `elpd_diff` is each fit's
#' difference from the best and `se_diff` its standard error. A difference small
#' relative to its standard error gives no clear preference between the fits.
#'
#' @param x A `kb_fit` object.
#' @param ... Passed to `loo::loo()`, for example `cores`.
#'
#' @return A `psis_loo` object from `loo::loo()`.
#' @references
#' Vehtari, A., Gelman, A., and Gabry, J. (2017). Practical Bayesian model
#' evaluation using leave-one-out cross-validation and WAIC. Statistics and
#' Computing, 27, 1413-1432.
#' @family generics
#' @seealso [log_lik()] for the pointwise log-likelihood.
#' @exportS3Method loo::loo
#' @examples
#' loo_weight <- loo(fit_weight_sim_nereo)
#' loo_weight
#' loo::pareto_k_values(loo_weight)
#'
#' # Compare the two forms of the Nereocystis weight model on the same data:
#' if (interactive()) {
#'   fit_power <- kb_fit_weight_nereo(data_weight_sim_nereo, form = "power")
#'   loo_compare(loo(fit_weight_sim_nereo), loo(fit_power))
#' }
loo.kb_fit <- function(x, ...) {
  .chk_kb_fit(x)
  # error_call() names the generic, not the method.
  .chk_loo_fit(x, call = rlang::error_call(rlang::current_env()))
  ll <- log_lik(x)
  # Stored draws are chain-major, so rows map onto the same chains.
  chain_id <- rep(
    seq_len(posterior::nchains(x$draws)),
    each = posterior::niterations(x$draws)
  )
  r_eff <- loo::relative_eff(exp(ll), chain_id = chain_id)
  loo::loo(ll, r_eff = r_eff, ...)
}
