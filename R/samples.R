#' @rdname samples
#' @export
samples.kb_fit <- function(fit, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit)
  fit$draws
}
