# A fit writes a pollable directory (a manifest plus rstan's per-chain
# sample_file CSVs) and a prediction a record of completed steps; the console
# bar and kb_progress() both read a completed fraction from it.

progress_sample_file <- function(dir) {
  file.path(dir, "samples.csv")
}

# rstan inserts _<chain> before the extension, but only for multiple chains.
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

# rstan saves thinned warmup rows as well as the post-warmup draws.
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

# Rows with the full field count only, so a partially written trailing row
# never over-counts.
count_chain_rows <- function(csv) {
  if (!file.exists(csv)) {
    return(0L)
  }
  lines <- tryCatch(readLines(csv, warn = FALSE), error = function(e) {
    character()
  })
  lines <- lines[nzchar(lines) & !startsWith(lines, "#")]
  header_at <- grep("lp__", lines, fixed = TRUE)
  if (!length(header_at)) {
    return(0L)
  }
  n_fields <- length(strsplit(lines[header_at[1]], ",", fixed = TRUE)[[1]])
  data_lines <- lines[-seq_len(header_at[1])]
  if (!length(data_lines)) {
    return(0L)
  }
  fields <- lengths(strsplit(data_lines, ",", fixed = TRUE))
  sum(fields == n_fields)
}

# Stan writes an "Elapsed Time" footer when a chain completes.
chain_is_complete <- function(csv) {
  if (!file.exists(csv)) {
    return(FALSE)
  }
  lines <- tryCatch(readLines(csv, warn = FALSE), error = function(e) {
    character()
  })
  any(grepl("Elapsed Time", lines, fixed = TRUE))
}

count_progress_rows <- function(dir, manifest) {
  per_chain <- progress_rows_per_chain(
    manifest$warmup,
    manifest$niters,
    manifest$nthin
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

# 0 before any artifact exists.
read_progress_fraction <- function(dir) {
  manifest <- read_progress_manifest(dir)
  if (is.null(manifest)) {
    return(0)
  }
  total <- progress_rows_per_chain(
    manifest$warmup,
    manifest$niters,
    manifest$nthin
  ) *
    manifest$chains
  if (total <= 0L) {
    return(0)
  }
  min(count_progress_rows(dir, manifest) / total, 1)
}

progress_prediction_file <- function(dir) {
  file.path(dir, "prediction.rds")
}

# Written to a temp file and renamed, so a reader in another process never sees
# a partial write.
write_prediction_progress <- function(dir, completed, total) {
  if (is.null(dir)) {
    return(invisible(NULL))
  }
  tmp <- tempfile("prediction-", tmpdir = dir, fileext = ".rds")
  saveRDS(list(completed = completed, total = total), tmp)
  file.rename(tmp, progress_prediction_file(dir))
  invisible(NULL)
}

# NULL when the directory holds no prediction record.
read_prediction_progress <- function(dir) {
  path <- progress_prediction_file(dir)
  if (!file.exists(path)) {
    return(NULL)
  }
  record <- tryCatch(readRDS(path), error = function(e) NULL)
  if (is.null(record) || record$total <= 0) {
    return(NULL)
  }
  min(record$completed / record$total, 1)
}

# A caller-supplied progress_dir is left in place; the "bar" otherwise gets a
# temp directory (owned = TRUE) that the caller removes on exit.
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

# "bar" binds a cli progress bar, every other value a no-op.
progress_reporter <- function(progress, label = "Fitting model") {
  if (identical(progress, "bar")) {
    return(bar_reporter(label))
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

bar_reporter <- function(label = "Fitting model") {
  id <- NULL
  structure(
    list(
      # Scoped to the caller's frame (the fit loop): in a detached environment
      # cli drops the bar between poll ticks ("cannot find progress bar").
      start = function(total) {
        id <<- cli::cli_progress_bar(
          label,
          total = total,
          format = paste(
            "{cli::pb_spin}", label, "{cli::pb_bar}",
            "{cli::pb_percent} | {cli::pb_eta_str}"
          ),
          format_done = paste(
            "{cli::col_green(cli::symbol$tick)}", label,
            "[{cli::pb_elapsed}]"
          ),
          clear = FALSE,
          .envir = parent.frame()
        )
      },
      # cli terminates the bar at total, after which updates error; progress
      # must never abort the fit.
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
