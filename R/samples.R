#' @rdname samples
#' @export
samples.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  x$draws
}
