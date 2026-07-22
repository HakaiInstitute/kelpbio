# Progress infrastructure for the fitting engine. A fit can write a kelpbio-owned,
# pollable artifact into a directory: a manifest plus rstan's per-chain
# sample_file CSVs. The row-counting here turns that artifact into a completed
# fraction, which both the console reporter (in fit_stan()) and the public
# kb_fit_progress() reader consume. See decisions in the change design (D3/D5/D6):
# rstan writes thinned warmup rows by default and a "# Elapsed Time" footer at
# chain completion; the exact row denominator is non-critical because completion
# is signalled by that footer (and, for real callers, out of band).

# Base name for the rstan sample_file; rstan appends _<chain> before the
# extension, giving samples_1.csv, samples_2.csv, ...
progress_sample_file <- function(dir) {
  file.path(dir, "samples.csv")
}

progress_chain_files <- function(dir, chains) {
  file.path(dir, sprintf("samples_%d.csv", seq_len(chains)))
}

progress_manifest_file <- function(dir) {
  file.path(dir, "manifest.rds")
}

# Saved rows a completed chain writes: thinned warmup plus the niters post-warmup
# draws.
progress_rows_per_chain <- function(warmup, niters, nthin) {
  as.integer(ceiling(warmup / nthin) + niters)
}

write_progress_manifest <- function(dir, chains, warmup, niters, nthin) {
  manifest <- list(
    chains = as.integer(chains),
    warmup = as.integer(warmup),
    niters = as.integer(niters),
    nthin = as.integer(nthin)
  )
  saveRDS(manifest, progress_manifest_file(dir))
  invisible(manifest)
}

read_progress_manifest <- function(dir) {
  path <- progress_manifest_file(dir)
  if (!file.exists(path)) {
    return(NULL)
  }
  tryCatch(readRDS(path), error = function(e) NULL)
}

# Complete data rows in one chain's CSV: non-comment lines after the header that
# have the full field count. A partially written trailing row has fewer fields
# and is ignored, so a torn read never errors or over-counts.
count_chain_rows <- function(csv) {
  if (!file.exists(csv)) {
    return(0L)
  }
  lines <- tryCatch(readLines(csv, warn = FALSE), error = function(e) character())
  lines <- lines[nzchar(lines) & !startsWith(lines, "#")]
  header_at <- which(grepl("lp__", lines, fixed = TRUE))
  if (!length(header_at)) {
    return(0L)
  }
  n_fields <- length(strsplit(lines[header_at[1]], ",", fixed = TRUE)[[1]])
  data_lines <- lines[-seq_len(header_at[1])]
  if (!length(data_lines)) {
    return(0L)
  }
  fields <- vapply(
    strsplit(data_lines, ",", fixed = TRUE), length, integer(1)
  )
  sum(fields == n_fields)
}

# A chain is complete once Stan has written its timing footer.
chain_is_complete <- function(csv) {
  if (!file.exists(csv)) {
    return(FALSE)
  }
  lines <- tryCatch(readLines(csv, warn = FALSE), error = function(e) character())
  any(grepl("Elapsed Time", lines, fixed = TRUE))
}

# Complete rows across all chains, capped per chain, treating a chain with its
# completion footer as fully done.
count_progress_rows <- function(dir, manifest) {
  per_chain <- progress_rows_per_chain(
    manifest$warmup, manifest$niters, manifest$nthin
  )
  files <- progress_chain_files(dir, manifest$chains)
  total <- 0L
  for (csv in files) {
    if (chain_is_complete(csv)) {
      total <- total + per_chain
    } else {
      total <- total + min(count_chain_rows(csv), per_chain)
    }
  }
  total
}

# Completed fraction in [0, 1]: 0 before any artifact or rows, 1 at completion.
read_progress_fraction <- function(dir) {
  manifest <- read_progress_manifest(dir)
  if (is.null(manifest)) {
    return(0)
  }
  total <- progress_rows_per_chain(
    manifest$warmup, manifest$niters, manifest$nthin
  ) * manifest$chains
  if (total <= 0L) {
    return(0)
  }
  min(count_progress_rows(dir, manifest) / total, 1)
}

# Resolve where (if anywhere) the pollable artifact is written. A caller-supplied
# progress_dir is used as-is and left in place; the console "bar" otherwise uses
# an internal temp directory (owned = TRUE, removed by the caller on exit).
# Other modes without a progress_dir write no artifact.
resolve_progress_dir <- function(progress, progress_dir) {
  if (!is.null(progress_dir)) {
    return(list(dir = progress_dir, owned = FALSE))
  }
  if (identical(progress, "bar")) {
    dir <- tempfile("kb_progress_")
    dir.create(dir)
    return(list(dir = dir, owned = TRUE))
  }
  list(dir = NULL, owned = FALSE)
}

# Console reporter seam: "bar" binds a cli progress bar, every other value a
# no-op. The reporter renders the fraction; it does not produce it, so the
# console bar and an external kb_fit_progress() poller share one signal.
progress_reporter <- function(progress) {
  if (identical(progress, "bar")) {
    return(bar_reporter())
  }
  noop_reporter()
}

noop_reporter <- function() {
  structure(
    list(
      start = function(total) invisible(NULL),
      update = function(completed) invisible(NULL),
      finish = function() invisible(NULL)
    ),
    class = c("kb_reporter_noop", "kb_reporter")
  )
}

bar_reporter <- function() {
  state <- new.env(parent = emptyenv())
  structure(
    list(
      start = function(total) {
        state$id <- cli::cli_progress_bar(
          "Fitting model",
          total = total,
          clear = FALSE,
          .envir = state
        )
      },
      update = function(completed) {
        cli::cli_progress_update(set = completed, id = state$id, .envir = state)
      },
      finish = function() {
        if (!is.null(state$id)) {
          cli::cli_progress_done(id = state$id, .envir = state)
        }
      }
    ),
    class = c("kb_reporter_bar", "kb_reporter")
  )
}
