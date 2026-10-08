#' Influential Observations
#'
#' Identify the observations that most influence a fit and those it predicts
#' poorly, by Pareto-smoothed importance-sampling leave-one-out cross-validation
#' (PSIS-LOO; Vehtari et al. 2017).
#'
#' @details
#' Each observation gets two values:
#'
#' - `pareto_k` measures how much the fit changes when the observation is left
#'   out. Values above about 0.7 mark an influential observation.
#' - `elpd_loo` is the log density of the observation under a fit that left it
#'   out. Lower values mark observations the model predicts poorly. Its scale
#'   depends on the response's units, so compare values within a fit.
#'
#' A deviance residual from [augment()] measures how far an observation is from
#' the fit, not how much the fit depends on it. A large residual in a
#' well-sampled site and year moves the estimates little, while a modest one at
#' the edge of the data, or in a site and year with few observations, can move
#' them a lot.
#'
#' Influential or poorly predicted observations are worth checking for recording
#' errors. An observation that checks out is valid data and should be kept:
#' influence often reflects a site and year with few observations rather than an
#' error. Many influential observations across the data suggest the model
#' describes the data poorly.
#'
#' The values are those of [loo::loo()] on the fit, computed from the stored draws
#' without refitting.
#'
#' @param fit A `kb_fit` object.
#' @param ... Unused.
#' @param threshold A number greater than 0: an observation with `pareto_k`
#'   above it is influential.
#'
#' @return The fitted data as a tibble, one row per observation, with added
#'   columns `elpd_loo`, `pareto_k`, and `influential`.
#' @references
#' Vehtari, A., Gelman, A., and Gabry, J. (2017). Practical Bayesian model
#' evaluation using leave-one-out cross-validation and WAIC. Statistics and
#' Computing, 27, 1413-1432.
#' @family model
#' @seealso [loo.kb_fit()] for the full PSIS-LOO result.
#' @export
#'
#' @examples
#' influence <- kb_influence(fit_weight_sim_nereo)
#' influence[influence$influential, ]
kb_influence <- function(fit, ..., threshold = 0.7) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit)
  chk::chk_number(threshold)
  chk::chk_gt(threshold)
  .chk_loo_fit(fit)

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
