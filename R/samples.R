#' @rdname samples
#' @export
samples.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(x)
  x$draws
}
