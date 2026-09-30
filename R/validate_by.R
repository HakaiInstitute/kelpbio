# Validate the `by` grouping axis of a `_by` prediction verb. Every kelpbio model
# with random effects carries the same three: year, site, and site:year where the
# design supports it. So membership in .group_vars() is the whole rule, and there
# is no per-model generic deciding which combinations a fit offers.
validate_by <- function(fit, by) {
  if (is.null(by)) {
    by <- character(0)
  }
  chk::chk_character(by)
  valid <- .group_vars()
  bad <- setdiff(by, valid)
  if (length(bad)) {
    cli::cli_abort(c(
      "Invalid {.arg by} value{?s}: {.val {bad}}.",
      i = "Available grouping factors: {.val {valid}}."
    ))
  }
  by
}
