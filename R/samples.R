#' @export
samples.default <- function(fit, ...) {
  .chk_kb_fit(fit, call = rlang::current_env())
  .abort_no_method("samples", fit, call = rlang::current_env())
}

#' @rdname samples
#' @export
samples.kb_fit <- function(fit, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit)
  fit$draws
}
