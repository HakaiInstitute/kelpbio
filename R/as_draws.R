#' @rdname kb_samples
#' @name kb_samples
#' @param x A `kb_fit` object.
#' @exportS3Method posterior::as_draws
as_draws.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(x)
  x$draws
}
