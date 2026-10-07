validate_by <- function(by) {
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
