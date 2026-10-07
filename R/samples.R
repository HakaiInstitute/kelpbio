#' Posterior Draws
#'
#' The posterior draws of the effects a fitted model estimated.
#'
#' @param fit A fitted model object.
#' @param ... Unused.
#' @return A `posterior` draws object.
#' @family generics
#' @export
#' @examples
#' samples(fit_weight_sim_nereo)
samples <- function(fit, ...) {
  UseMethod("samples")
}

#' @export
samples.default <- function(fit, ...) {
  .chk_kb_fit(fit, call = rlang::current_env())
  .abort_no_method(fit, call = rlang::current_env())
}

#' @rdname samples
#' @export
samples.kb_fit <- function(fit, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit)
  .fitted_draws(fit)
}
