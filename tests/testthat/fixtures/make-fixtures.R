# Build cached test fixtures. NOT run during testing.
#
# Requires the compiled package (run `devtools::install()` or
# `devtools::load_all()` first; `load_all()` does not pick up Stan changes, so
# reinstall after editing inst/stan/weight.stan). Re-run this script whenever the
# Stan model or the kb_fit object structure changes. Reproducibility comes from
# the sampler `seed`, not `set.seed()`.
#
# Run from the package root:  Rscript tests/testthat/fixtures/make-fixtures.R

devtools::load_all(quiet = TRUE)

# A small slice of the simulated data (see make-sim-data.R) spanning several
# sites and years so that by = "site" and by = c("site", "year") predictions are
# exercised downstream. Independent of the real bundled data_weight_hakai.
sim_weight <- readRDS("tests/testthat/fixtures/sim_weight.rds")
d <- subset(
  sim_weight,
  site %in% c("site1", "site2", "site3", "site4") &
    year %in% c("2019", "2020", "2021")
)
d$site <- factor(d$site)
d$year <- factor(d$year)

weight_fit <- kb_fit_weight(
  d,
  chains = 2L, niters = 300L, nthin = 1L, cores = 2L,
  quiet = TRUE, seed = 42L
)

saveRDS(weight_fit, "tests/testthat/fixtures/weight_fit.rds")
message("Wrote tests/testthat/fixtures/weight_fit.rds")
