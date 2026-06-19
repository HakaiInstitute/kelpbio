#' Pointwise Log-Likelihood
#'
#' The pointwise log-likelihood of the observed data (from the Stan generated
#' quantities), suitable for `loo::loo()`.
#'
#' @param object A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return A draws-by-observations (`D x N`) matrix.
#' @family generics
#' @exportS3Method rstantools::log_lik
log_lik.kb_fit_weight <- function(object, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit_weight(object)
  if (is.null(object$gq)) {
    cli::cli_abort("No pointwise log-likelihood is stored (zero-observation fit).")
  }
  posterior::draws_of(object$gq$log_lik)
}
