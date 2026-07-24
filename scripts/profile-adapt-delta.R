# Profile: how does adapt_delta trade fit time against sampler accuracy?
#
# The weight model defaults to adapt_delta = 0.95, which forces a small
# HMC step size and thus more leapfrog steps (slower) per iteration. Lowering
# it speeds sampling but risks divergent transitions (biased posterior). This
# sweeps a few values, timing each fit and recording the accuracy cost
# (divergences, max Rhat) so the default can be chosen on evidence.
#
# Fit on the bundled sim data (975 rows, 10 sites, 4 years), which is close to
# the real Hakai weight dataset (1140 rows, 28 sites, 7 years), so timings are
# representative of a real fit.
#
# Run from the package root:  Rscript scripts/profile-adapt-delta.R
# Absolute times are NOT comparable to benchmark-progress.R (fewer iterations
# here); read the columns relative to each other.

devtools::load_all(quiet = TRUE)

ADAPT_DELTA <- c(0.80, 0.90, 0.95, 0.99)
REPS <- 2L
NITERS <- 500L
CHAINS <- 4L
CORES <- min(CHAINS, parallel::detectCores())
SEED <- 1L

data <- data_weight_sim_nereo

# One seed-matched fit at the given adapt_delta; returns wall-clock seconds plus
# the accuracy diagnostics that adapt_delta is meant to protect.
one_fit <- function(adapt_delta) {
  elapsed <- NA_real_
  fit <- NULL
  elapsed <- system.time(
    fit <- kb_fit_weight_nereo(
      data,
      chains = CHAINS,
      niters = NITERS,
      cores = CORES,
      seed = SEED,
      progress = "none",
      control = list(adapt_delta = adapt_delta)
    )
  )["elapsed"]
  list(
    elapsed = unname(elapsed),
    ndivergent = fit$diagnostics$ndivergent,
    max_rhat = max(fit$diagnostics$summary$rhat, na.rm = TRUE)
  )
}

cat(sprintf(
  "chains=%d cores=%d niters=%d reps=%d\n\n",
  CHAINS,
  CORES,
  NITERS,
  REPS
))

# Warm-up fit (discarded) so one-time costs miss the first timed value.
invisible(one_fit(0.95))

cat(sprintf(
  "%-11s  %-22s  %-8s  %-11s  %s\n",
  "adapt_delta",
  "elapsed (s)",
  "median",
  "divergences",
  "max_rhat"
))
for (ad in ADAPT_DELTA) {
  runs <- lapply(seq_len(REPS), function(i) one_fit(ad))
  secs <- vapply(runs, `[[`, numeric(1), "elapsed")
  div <- vapply(runs, `[[`, numeric(1), "ndivergent")
  rh <- vapply(runs, `[[`, numeric(1), "max_rhat")
  cat(sprintf(
    "%-11.2f  %-22s  %-8.1f  %-11s  %.3f\n",
    ad,
    paste(sprintf("%.1f", secs), collapse = " "),
    median(secs),
    paste(div, collapse = "/"),
    max(rh)
  ))
}
