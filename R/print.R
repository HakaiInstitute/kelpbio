# Print methods use cli's cat_*/format_inline family (which write to stdout, as
# print methods must) rather than the cli_*() condition functions (which emit to
# the message stream). format_inline renders the cli markup (e.g. {.cls}).

#' @export
print.kb_prior_normal <- function(x, ...) {
  cli::cat_line(cli::format_inline(
    "normal(mean = {format(x$mean)}, sd = {format(x$sd)})"
  ))
  invisible(x)
}

#' @export
print.kb_prior_exponential <- function(x, ...) {
  cli::cat_line(cli::format_inline("exponential(rate = {format(x$rate)})"))
  invisible(x)
}

#' @export
print.kb_fit <- function(x, ...) {
  cli::cat_line(cli::format_inline("{.cls {class(x)[1]}}"))
  cli::cat_line("model:        ", sub("^kb_fit_", "", class(x)[1]))
  cli::cat_line("species:      ", x$meta$species)
  cli::cat_line("observations: ", nobs(x))
  cli::cat_line(
    "draws:        ", posterior::ndraws(x$draws), " (", nchains(x), " chains)"
  )
  cli::cat_line("converged:    ", converged(x))
  invisible(x)
}

#' @export
print.summary_kb_fit <- function(x, ...) {
  cli::cat_line(cli::format_inline("{.cls summary_kb_fit}"))
  cli::cat_line("model:        ", x$model)
  cli::cat_line("species:      ", x$species)
  cli::cat_line("observations: ", x$nobs)
  cli::cat_line("converged:    ", x$converged)
  cli::cat_line("")
  print(x$coefficients, ...)
  invisible(x)
}

#' @export
print.kb_predictions <- function(x, ...) {
  gv <- attr(x, "kb_group_vars")
  by <- if (length(gv)) paste0(" | by: ", paste(gv, collapse = ", ")) else ""
  cli::cat_line(
    cli::format_inline(
      "{.cls kb_predictions} predictor: {attr(x, 'kb_predictor')} | response: {attr(x, 'kb_response')}"
    ),
    by
  )
  print(tibble::as_tibble(x), ...)
  invisible(x)
}
