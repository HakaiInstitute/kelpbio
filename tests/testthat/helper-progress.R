# Mimics one rstan sample_file chain CSV, optionally with a torn (short) last
# row and the "# Elapsed Time" completion footer.
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
