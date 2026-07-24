# Build cached test fixtures. NOT run during testing.
#
# Requires the compiled package (run `devtools::install()` or
# `devtools::load_all()` first; `load_all()` does not pick up Stan changes, so
# reinstall after editing inst/stan/weight_nereo.stan). Re-run this script whenever the
# Stan model or the kb_fit object structure changes. Reproducibility comes from
# the sampler `seed`, not `set.seed()`.
#
# Run from the package root:  Rscript tests/testthat/fixtures/make-fixtures.R

devtools::load_all(quiet = TRUE)

# A small slice of the bundled simulated dataset spanning several sites and years
# so that by = "site" and by = c("site", "year") predictions are exercised
# downstream. Using a subset of data_weight_sim_nereo keeps a single simulation
# source (there is no separate test-only simulator).
d <- subset(
  data_weight_sim_nereo,
  site %in%
    c("site1", "site2", "site3", "site4") &
    year %in% c("2019", "2020", "2021")
)
d$site <- droplevels(factor(d$site))
d$year <- droplevels(factor(d$year))

weight_fit <- kb_fit_weight_nereo(
  d,
  chains = 2L,
  niters = 300L,
  nthin = 1L,
  cores = 2L,
  progress = "none",
  seed = 42L
)

saveRDS(weight_fit, "tests/testthat/fixtures/weight_fit.rds")
message("Wrote tests/testthat/fixtures/weight_fit.rds")

# Macrocystis fixture (Gamma weight model), same downsampling approach.
sim_weight_macro <- readRDS("tests/testthat/fixtures/sim_weight_macro.rds")
dm <- subset(
  sim_weight_macro,
  site %in%
    c("site1", "site2", "site3", "site4") &
    year %in% c("2019", "2020", "2021")
)
dm$site <- factor(dm$site)
dm$year <- factor(dm$year)

weight_macro_fit <- kb_fit_weight_macro(
  dm,
  chains = 2L,
  niters = 300L,
  nthin = 1L,
  cores = 2L,
  progress = "none",
  seed = 42L
)

saveRDS(weight_macro_fit, "tests/testthat/fixtures/weight_macro_fit.rds")
message("Wrote tests/testthat/fixtures/weight_macro_fit.rds")
