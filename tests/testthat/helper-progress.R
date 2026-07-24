# Fixture writer mimicking one rstan sample_file chain CSV: leading comment
# lines, a header row containing lp__, `n_rows` complete data rows, an optional
# torn (short) trailing row, and an optional "# Elapsed Time" completion footer.
# Shared by test-progress.R and test-kb_fit_progress.R.
write_fake_chain <- function(
  path,
  n_fields = 5L,
  n_rows = 3L,
  torn = FALSE,
  complete = FALSE
) {
  header <- paste(
    c("lp__", paste0("v", seq_len(n_fields - 1L))),
    collapse = ","
  )
  row <- paste(as.character(seq_len(n_fields)), collapse = ",")
  lines <- c(
    "# comment: adaptation config",
    header,
    rep(row, n_rows)
  )
  if (torn) {
    lines <- c(
      lines,
      paste(as.character(seq_len(n_fields - 2L)), collapse = ",")
    )
  }
  if (complete) {
    lines <- c(lines, "# ", "#  Elapsed Time: 1.0 seconds (Total)")
  }
  writeLines(lines, path)
  invisible(path)
}
