#' Stan Source for a Model Fit
#'
#' Return the Stan source code of the fitted model.
#'
#' @param x A `kb_fit` object.
#' @param ... Unused.
#'
#' @return The Stan source as a string.
#' @export
kb_stancode <- function(x, ...) {
  UseMethod("kb_stancode")
}

#' @rdname kb_stancode
#' @export
kb_stancode.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  x$meta$stancode
}
