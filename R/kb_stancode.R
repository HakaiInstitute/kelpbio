#' Stan Source for a Model Fit
#'
#' Return the Stan source code of the fitted model.
#'
#' @param x A `kb_fit` object.
#' @param ... Unused.
#'
#' @return A `kb_stancode` object: the Stan source string, which prints as
#'   readable code. Use [as.character()] for the plain string.
#' @family generics
#' @export
#'
#' @examples
#' kb_stancode(fit_weight_sim_nereo)
kb_stancode <- function(x, ...) {
  UseMethod("kb_stancode")
}

#' @rdname kb_stancode
#' @export
kb_stancode.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(x)
  # as.character() drops the model_name attribute rstan::get_stancode() carries,
  # leaving a clean classed string.
  structure(as.character(x$meta$stancode), class = "kb_stancode")
}
