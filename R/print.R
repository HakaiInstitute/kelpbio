#' @export
print.kb_prior_normal <- function(x, ...) {
  cat(sprintf("normal(mean = %s, sd = %s)\n", format(x$mean), format(x$sd)))
  invisible(x)
}

#' @export
print.kb_prior_exponential <- function(x, ...) {
  cat(sprintf("exponential(rate = %s)\n", format(x$rate)))
  invisible(x)
}
