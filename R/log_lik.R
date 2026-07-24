#' Pointwise Log-Likelihood
#'
#' The pointwise log-likelihood of the observed data (from the Stan generated
#' quantities), suitable for `loo::loo()`.
#'
#' @param object A `kb_fit` object.
#' @param ... Unused.
#'
#' @return A draws-by-observations (`D x N`) matrix.
#' @family generics
#' @exportS3Method rstantools::log_lik
#' @examples
#' ll <- log_lik(fit_weight_sim_nereo)
#' dim(ll)
log_lik.kb_fit <- function(object, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(object)
  if (is.null(object$gq)) {
    cli::cli_abort(
      "No pointwise log-likelihood is stored (zero-observation fit)."
    )
  }
  posterior::draws_of(object$gq$log_lik)
}
