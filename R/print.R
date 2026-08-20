# Print methods use cli's cat_*/format_inline (stdout, as print methods must),
# not the cli_*() condition functions (message stream). format_inline renders the
# cli markup (e.g. {.cls}).

#' @export
print.kb_stancode <- function(x, ...) {
  cat(unclass(x), sep = "\n")
  invisible(x)
}

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

# A diagnostic rate for display: 3 significant figures with a "%" suffix, or
# "unknown" when the rate has no denominator (a fit with no draws).
.fmt_perc <- function(x) {
  if (is.na(x)) {
    return("unknown")
  }
  paste0(format(signif(x, 3)), "%")
}

# Render the shared fit metadata header (used by print.kb_fit and
# print.summary_kb_fit). `h` is the field list from .kb_fit_header(); the
# summary_kb_fit object carries the same fields.
.print_kb_fit_header <- function(h) {
  cli::cat_line("Model:     ", h$model, " (", h$species, ")")
  if (!is.na(h$predictor)) {
    cli::cat_line("Predictor: ", h$predictor)
  }
  groups <- if (length(h$groups)) {
    paste0(
      "; groups: ",
      paste0(names(h$groups), " (", h$groups, ")", collapse = ", ")
    )
  } else {
    ""
  }
  cli::cat_line("Data:      ", h$nobs, " observations", groups)
  cli::cat_line(
    "Draws:     ",
    h$nchains,
    " chains, ",
    h$niters,
    " post-warmup draws each (thin = ",
    h$nthin,
    "), ",
    h$ndraws,
    " total"
  )
  if (isTRUE(h$prior_only)) {
    cli::cat_line("Note:      prior-only fit (likelihood off)")
  }
  cli::cat_line("Converged: ", h$converged)
}

#' @export
print.kb_fit <- function(x, ...) {
  cli::cat_line(cli::format_inline("{.cls {class(x)[1]}}"))
  .print_kb_fit_header(.kb_fit_header(x))
  cli::cat_line(cli::col_grey(
    "See kb_model_describe(fit) for the model equation and priors."
  ))
  invisible(x)
}

#' @export
print.summary_kb_fit <- function(x, ...) {
  cli::cat_line(cli::format_inline("{.cls summary_kb_fit}"))
  .print_kb_fit_header(x)
  cli::cat_line("")
  print(x$coefficients, ...)
  cli::cat_line("")
  pct <- format(x$conf_level * 100)
  cli::cat_line(cli::col_grey(
    "estimate: posterior point estimate; lower, upper: ",
    pct,
    "% compatibility limits."
  ))
  cli::cat_line(cli::col_grey(
    "rhat: potential scale reduction factor (1 at convergence)."
  ))
  cli::cat_line(cli::col_grey(
    "ess_bulk, ess_tail: bulk and tail effective sample sizes."
  ))
  # Rates are rounded here, at the display boundary; the fit stores them unrounded.
  cli::cat_line(cli::col_grey(
    .fmt_perc(x$perc_divergent),
    " divergent transitions; ",
    .fmt_perc(x$perc_max_treedepth),
    " max-treedepth; min E-BFMI ",
    format(signif(x$ebfmi, 3)),
    "."
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
