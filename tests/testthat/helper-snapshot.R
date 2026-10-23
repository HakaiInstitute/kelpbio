# Redact the parts of a printed fit or summary that depend on the draws or the
# data, so the snapshot survives fixture rebuilds: convergence, the predictor
# reference value, the summary table's numerics, and the sampler footer.
redact_fit_print <- function(lines) {
  lines <- sub("^(\\s*\\d+ \\S+)\\s+[-0-9.].*$", "\\1 <numerics>", lines)
  lines <- sub("^(Predictor: [a-z_]+, reference) [0-9.]+", "\\1 <value>", lines)
  lines <- sub("^(Converged:) .*$", "\\1 <value>", lines)
  sub(
    "^[0-9.]+% divergent.*min E-BFMI [0-9.]+\\.$",
    "<n>% divergent transitions; <n>% max-treedepth; min E-BFMI <n>.",
    lines
  )
}

# Snapshot a table as a CSV file, one per name in the test file's _snaps
# folder. Columns of draws are dropped (their summaries are the estimate,
# lower and upper columns) and doubles rounded, so the file changes only when
# the code or the fixtures do.
expect_snapshot_data <- function(x, name, digits = 3) {
  x <- tibble::as_tibble(x)
  x <- dplyr::select(x, !dplyr::where(posterior::is_rvar))
  x <- dplyr::mutate(
    x,
    dplyr::across(dplyr::where(is.double), function(col) signif(col, digits))
  )
  path <- withr::local_tempfile(fileext = ".csv")
  utils::write.csv(x, path, row.names = FALSE)
  testthat::expect_snapshot_file(
    path,
    paste0(name, ".csv"),
    compare = testthat::compare_file_text
  )
}
