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

#' @export
print.kb_fit <- function(x, ...) {
  model <- sub("^kb_fit_", "", class(x)[1])
  cat("<", class(x)[1], ">\n", sep = "")
  cat("model:        ", model, "\n", sep = "")
  cat("species:      ", x$meta$species, "\n", sep = "")
  cat("observations: ", nobs(x), "\n", sep = "")
  cat("draws:        ", posterior::ndraws(x$draws),
    " (", nchains(x), " chains)\n",
    sep = ""
  )
  cat("converged:    ", converged(x), "\n", sep = "")
  invisible(x)
}
