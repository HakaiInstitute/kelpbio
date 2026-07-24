# Check a fit is reproducible in every progress mode, both from an explicit
# `seed` and from a preceding set.seed(). The "bar" path samples in a callr
# subprocess with its own RNG, the case worth verifying.
#
# Prints a PASS/FAIL table (maxdiff 0 = reproducible). Fits MCMC (~minutes):
#   Rscript scripts/check-seed-reproducibility.R

devtools::load_all(quiet = TRUE)

SEED <- 1L
CHAINS <- 2L
NITERS <- 200L
CORES <- min(CHAINS, parallel::detectCores())

data <- data_weight_sim_nereo

# Fit once and return the posterior draws as a plain matrix for exact comparison.
# Supply `seed` for the explicit route, or `set_seed` to set R's RNG first and
# let rstan derive its own seed (the implicit route).
fit_draws <- function(progress, seed = NULL, set_seed = NULL) {
  if (!is.null(set_seed)) {
    set.seed(set_seed)
  }
  fit <- kb_fit_weight_nereo(
    data,
    chains = CHAINS,
    niters = NITERS,
    nthin = 1L,
    cores = CORES,
    progress = progress,
    seed = seed
  )
  posterior::as_draws_matrix(fit$draws)
}

# Largest absolute difference between two draw matrices; 0 means bit-identical.
maxdiff <- function(a, b) {
  max(abs(as.numeric(a) - as.numeric(b)))
}

# Each row: fit twice the same way and compare. The explicit cross-mode row
# checks that a shared seed gives the same draws in-process and in the subprocess.
rows <- list(
  list(label = "explicit seed, none x2", a = list(progress = "none", seed = SEED), b = list(progress = "none", seed = SEED)),
  list(label = "explicit seed, bar x2", a = list(progress = "bar", seed = SEED), b = list(progress = "bar", seed = SEED)),
  list(label = "explicit seed, none vs bar", a = list(progress = "none", seed = SEED), b = list(progress = "bar", seed = SEED)),
  list(label = "set.seed(), none x2", a = list(progress = "none", set_seed = SEED), b = list(progress = "none", set_seed = SEED)),
  list(label = "set.seed(), bar x2", a = list(progress = "bar", set_seed = SEED), b = list(progress = "bar", set_seed = SEED))
)

cat(sprintf("chains=%d niters=%d cores=%d seed=%d\n\n", CHAINS, NITERS, CORES, SEED))

results <- lapply(rows, function(row) {
  d <- maxdiff(do.call(fit_draws, row$a), do.call(fit_draws, row$b))
  cat(sprintf(
    "%-27s maxdiff=%-12.6g %s\n",
    row$label,
    d,
    if (d == 0) "PASS" else "FAIL"
  ))
  d
})

if (all(vapply(results, function(d) d == 0, logical(1)))) {
  cat("\nAll routes reproducible.\n")
} else {
  cat("\nSome routes are not reproducible (see FAIL rows above).\n")
}
