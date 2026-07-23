# Benchmark: does progress = "bar" slow down fitting, and if so, which layer?
#
# The "bar" path adds two things on top of a plain in-process fit:
#   1. sample_file: rstan writes every draw to a CSV on disk (I/O per iteration).
#   2. a callr subprocess running the sampler, polled every POLL_INTERVAL.
#
# These are isolated with three conditions, all fit in-process except the last:
#   A baseline   progress = "none"                  in-process, no CSV
#   B csv_only   progress = "none" + progress_dir   in-process, writes the CSV
#   C bar        progress = "bar"                    subprocess + CSV + polling
#
# so:  CSV I/O cost       = B - A
#      subprocess + poll  = C - B
#      total bar overhead = C - A
#
# Run from the package root:  Rscript scripts/benchmark-progress.R
# (or source("scripts/benchmark-progress.R") in a session at the repo root).
# Scale REPS / NITERS up if the times are too noisy to read.

devtools::load_all(quiet = TRUE)

REPS <- 3L
NITERS <- 500L
NTHIN <- 2L
CHAINS <- 4L
CORES <- min(CHAINS, parallel::detectCores())
SEED <- 1L

data <- data_weight_sim_nereo

# Elapsed wall-clock seconds for one fit under the given progress settings. A
# fresh seed-matched fit each call so every condition does identical work.
time_fit <- function(progress, progress_dir = NULL) {
  t <- system.time(
    kb_fit_weight_nereo(
      data,
      chains = CHAINS,
      niters = NITERS,
      nthin = NTHIN,
      cores = CORES,
      seed = SEED,
      progress = progress,
      progress_dir = progress_dir
    )
  )
  unname(t["elapsed"])
}

# One temp dir reused for the CSV-writing conditions (contents overwritten).
csv_dir <- tempfile("bench_csv_")
dir.create(csv_dir)

conditions <- list(
  baseline = function() time_fit("none"),
  csv_only = function() time_fit("none", progress_dir = csv_dir),
  bar = function() time_fit("bar")
)

cat(sprintf(
  "chains=%d cores=%d niters=%d reps=%d\n\n",
  CHAINS,
  CORES,
  NITERS,
  REPS
))

# Warm-up fit (discarded): pays one-time costs (JIT, disk warm, callr image)
# so they do not land on whichever condition runs first.
invisible(time_fit("none"))

results <- lapply(conditions, function(f) {
  vapply(seq_len(REPS), function(i) f(), numeric(1))
})

med <- vapply(results, median, numeric(1))
for (nm in names(results)) {
  cat(sprintf(
    "%-9s  reps: %s  median: %.2fs\n",
    nm,
    paste(sprintf("%.2f", results[[nm]]), collapse = " "),
    med[[nm]]
  ))
}

cat(sprintf(
  "\nCSV I/O cost        (csv_only - baseline): %+.2fs (%+.0f%%)\n",
  med["csv_only"] - med["baseline"],
  100 * (med["csv_only"] / med["baseline"] - 1)
))
cat(sprintf(
  "subprocess + poll   (bar - csv_only):      %+.2fs (%+.0f%%)\n",
  med["bar"] - med["csv_only"],
  100 * (med["bar"] / med["csv_only"] - 1)
))
cat(sprintf(
  "total bar overhead  (bar - baseline):      %+.2fs (%+.0f%%)\n",
  med["bar"] - med["baseline"],
  100 * (med["bar"] / med["baseline"] - 1)
))

unlink(csv_dir, recursive = TRUE)
