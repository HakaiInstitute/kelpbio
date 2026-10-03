# Build cached test fixtures. NOT run during testing.
#
# Requires the compiled package (run `devtools::install()` or
# `devtools::load_all()` first; `load_all()` does not pick up Stan changes, so
# reinstall after editing inst/stan/weight_nereo.stan). Re-run this script whenever the
# Stan model or the kb_fit object structure changes. Reproducibility comes from
# the sampler `seed`, not `set.seed()`.
#
# Run from the package root:  Rscript tests/testthat/fixtures/make-fixtures.R
# With model names as arguments, only those models' fixtures are rebuilt:
#   Rscript tests/testthat/fixtures/make-fixtures.R density wetdry

devtools::load_all(quiet = TRUE)

models <- c("weight", "size", "density", "wetdry")
selected <- commandArgs(trailingOnly = TRUE)
if (!length(selected)) {
  selected <- models
}
unknown <- setdiff(selected, models)
if (length(unknown)) {
  stop("Unknown model: ", paste(unknown, collapse = ", "), call. = FALSE)
}

# Size and density fixtures use subsets of the bundled data_size_sim_* and
# data_density_sim_*, mirroring the weight fixtures.
size_subset <- function(data) {
  d <- subset(data, site %in% c("site1", "site2", "site3", "site4"))
  d$site <- droplevels(factor(d$site))
  d$year <- droplevels(factor(d$year))
  d
}

if ("weight" %in% selected) {
  # A small slice of the bundled simulated dataset spanning several sites and years
  # so that by = "site" and by = c("site", "year") predictions are exercised
  # downstream. Using a subset of data_weight_sim_nereo keeps a single simulation
  # source (there is no separate test-only simulator). All four years are kept, so
  # the year SD is less weakly identified. These fixtures test structure, not
  # inference, and may not meet the strict converged() thresholds.
  d <- subset(
    data_weight_sim_nereo,
    site %in% c("site1", "site2", "site3", "site4")
  )
  d$site <- droplevels(factor(d$site))
  d$year <- droplevels(factor(d$year))

  weight_fit <- kb_fit_weight_nereo(
    d,
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L,
    # Raised above the 0.95 default so these deliberately small fits still clear
    # the convergence thresholds without lengthening the chains (and so growing
    # the stored objects).
    control = list(adapt_delta = 0.999)
  )

  saveRDS(weight_fit, "tests/testthat/fixtures/weight_fit.rds")
  message("Wrote tests/testthat/fixtures/weight_fit.rds")

  # Macrocystis fixture (Gamma weight model): a subset of the bundled
  # data_weight_sim_macro, mirroring the nereo fixture above (single source).
  dm <- subset(
    data_weight_sim_macro,
    site %in%
      c("site1", "site2", "site3", "site4") &
      year %in% c("2019", "2020", "2021")
  )
  dm$site <- droplevels(factor(dm$site))
  dm$year <- droplevels(factor(dm$year))

  weight_macro_fit <- kb_fit_weight_macro(
    dm,
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L,
    # Raised above the 0.95 default so these deliberately small fits still clear
    # the convergence thresholds without lengthening the chains (and so growing
    # the stored objects).
    control = list(adapt_delta = 0.999)
  )

  saveRDS(weight_macro_fit, "tests/testthat/fixtures/weight_macro_fit.rds")
  message("Wrote tests/testthat/fixtures/weight_macro_fit.rds")
}

if ("size" %in% selected) {
  size_nereo_fit <- kb_fit_size_nereo(
    size_subset(data_size_sim_nereo),
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L,
    control = list(adapt_delta = 0.999)
  )
  saveRDS(size_nereo_fit, "tests/testthat/fixtures/size_nereo_fit.rds")
  message("Wrote tests/testthat/fixtures/size_nereo_fit.rds")

  size_macro_fit <- kb_fit_size_macro(
    size_subset(data_size_sim_macro),
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L,
    control = list(adapt_delta = 0.999)
  )
  saveRDS(size_macro_fit, "tests/testthat/fixtures/size_macro_fit.rds")
  message("Wrote tests/testthat/fixtures/size_macro_fit.rds")
}

if ("density" %in% selected) {
  density_nereo_fit <- kb_fit_density_nereo(
    size_subset(data_density_sim_nereo),
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L,
    control = list(adapt_delta = 0.999)
  )
  saveRDS(density_nereo_fit, "tests/testthat/fixtures/density_nereo_fit.rds")
  message("Wrote tests/testthat/fixtures/density_nereo_fit.rds")

  density_macro_fit <- kb_fit_density_macro(
    size_subset(data_density_sim_macro),
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L,
    control = list(adapt_delta = 0.999)
  )
  saveRDS(density_macro_fit, "tests/testthat/fixtures/density_macro_fit.rds")
  message("Wrote tests/testthat/fixtures/density_macro_fit.rds")
}

if ("wetdry" %in% selected) {
  # Wet/dry fixtures: the first 80 samples of the bundled data_wetdry_sim_*, which
  # have no grouping factors to subset by.
  wetdry_nereo_fit <- kb_fit_wetdry_nereo(
    data_wetdry_sim_nereo[1:80, ],
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L
  )
  saveRDS(wetdry_nereo_fit, "tests/testthat/fixtures/wetdry_nereo_fit.rds")
  message("Wrote tests/testthat/fixtures/wetdry_nereo_fit.rds")

  wetdry_macro_fit <- kb_fit_wetdry_macro(
    data_wetdry_sim_macro[1:80, ],
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L
  )
  saveRDS(wetdry_macro_fit, "tests/testthat/fixtures/wetdry_macro_fit.rds")
  message("Wrote tests/testthat/fixtures/wetdry_macro_fit.rds")
}
