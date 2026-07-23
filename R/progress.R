# Progress infrastructure for the fitting engine. A fit can write a kelpbio-owned,
# pollable artifact (a manifest plus rstan's per-chain sample_file CSVs) that the
# console reporter and the public kb_fit_progress() reader turn into a completed
# fraction. rstan writes thinned warmup rows by default and an "# Elapsed Time"
# footer at chain completion (see the change design for the full rationale).

# Base name for the rstan sample_file; rstan appends _<chain> before the
# extension, giving samples_1.csv, samples_2.csv, ...
progress_sample_file <- function(dir) {
  file.path(dir, "samples.csv")
}

# rstan writes the sample_file as-is for a single chain, and inserts _<chain>
# before the extension (samples_1.csv, samples_2.csv, ...) for multiple chains.
progress_chain_files <- function(dir, chains) {
  base <- progress_sample_file(dir)
  if (chains == 1L) {
    return(base)
  }
  purrr::map_chr(
    seq_len(chains),
    function(i) sub("\\.csv$", sprintf("_%d.csv", i), base)
  )
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
  fields <- purrr::map_int(strsplit(data_lines, ",", fixed = TRUE), length)
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
  sum(purrr::map_int(files, function(csv) {
    if (chain_is_complete(csv)) {
      per_chain
    } else {
      min(count_chain_rows(csv), per_chain)
    }
  }))
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
  id <- NULL
  structure(
    list(
      # Scope the bar to the caller's frame (the fit loop, alive for the whole
      # run) via .envir = parent.frame(); a detached environment is not on the
      # call stack, so cli would drop the bar between poll ticks ("cannot find
      # progress bar"). The bar is looked up by id thereafter.
      start = function(total) {
        id <<- cli::cli_progress_bar(
          "Fitting model",
          total = total,
          format = paste(
            "{cli::pb_spin} Fitting model {cli::pb_bar}",
            "{cli::pb_percent} | {cli::pb_eta_str}"
          ),
          format_done = paste(
            "{cli::col_green(cli::symbol$tick)} Fitting model",
            "[{cli::pb_elapsed}]"
          ),
          clear = FALSE,
          .envir = parent.frame()
        )
      },
      # cli auto-terminates the bar once it reaches total, after which a further
      # update()/finish() errors. Progress is cosmetic and must never abort the
      # fit, so tolerate a since-terminated bar.
      update = function(completed) {
        tryCatch(
          cli::cli_progress_update(set = completed, id = id),
          error = function(e) invisible(NULL)
        )
      },
      finish = function() {
        if (!is.null(id)) {
          tryCatch(
            cli::cli_progress_done(id = id),
            error = function(e) invisible(NULL)
          )
        }
      }
    ),
    class = c("kb_reporter_bar", "kb_reporter")
  )
}
