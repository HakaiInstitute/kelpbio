# Print methods use cli's cat_*/format_inline (stdout, as print methods must),
# not the cli_*() condition functions (message stream). format_inline renders the
# cli markup (e.g. {.cls}).

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
  cli::cat_line("Model:     ", x$model, " (", x$species, ")")
  if (!is.na(x$family)) cli::cat_line("Family:    ", x$family)
  if (!is.na(x$formula)) cli::cat_line("Formula:   ", x$formula)
  groups <- if (length(x$groups)) {
    paste0("; groups: ", paste0(names(x$groups), " (", x$groups, ")", collapse = ", "))
  } else {
    ""
  }
  cli::cat_line("Data:      ", x$nobs, " observations", groups)
  cli::cat_line(
    "Draws:     ", x$nchains, " chains, ", x$niters,
    " post-warmup draws each (thin = ", x$nthin, "), ", x$ndraws, " total"
  )
  if (isTRUE(x$prior_only)) {
    cli::cat_line("Note:      prior-only fit (likelihood off)")
  }
  cli::cat_line("Converged: ", x$converged)
  cli::cat_line("")
  print(x$coefficients, ...)
  cli::cat_line("")
  pct <- format(x$conf_level * 100)
  cli::cat_line(cli::col_grey(
    "estimate: posterior point estimate; lower, upper: ", pct,
    "% compatibility limits."
  ))
  cli::cat_line(cli::col_grey(
    "rhat: potential scale reduction factor (1 at convergence)."
  ))
  cli::cat_line(cli::col_grey(
    "ess_bulk, ess_tail: bulk and tail effective sample sizes."
  ))
  cli::cat_line(cli::col_grey(
    x$ndivergent, " divergent transition", if (x$ndivergent == 1) "" else "s", "."
  ))
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
