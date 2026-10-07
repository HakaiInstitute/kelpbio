# Builds the cached test fixtures; not run during testing. From the package
# root, optionally naming models to rebuild only those:
#   Rscript tests/testthat/fixtures/make-fixtures.R density wetdry

devtools::load_all(quiet = TRUE)

models <- c("weight", "size", "density", "wetdry", "carbon", "cover_biomass")
selected <- commandArgs(trailingOnly = TRUE)
if (!length(selected)) {
  selected <- models
}
unknown <- setdiff(selected, models)
if (length(unknown)) {
  stop("Unknown model: ", paste(unknown, collapse = ", "), call. = FALSE)
}

size_subset <- function(data) {
  d <- subset(data, site %in% levels(data$site)[1:4])
  d$site <- droplevels(factor(d$site))
  d$year <- droplevels(factor(d$year))
  d
}

if ("weight" %in% selected) {
  # Several sites and years so by = "site" and c("site", "year") predictions are
  # exercised.
  d <- subset(
    data_weight_sim_nereo,
    site %in% levels(data_weight_sim_nereo$site)[1:4]
  )
  d$site <- droplevels(factor(d$site))
  d$year <- droplevels(factor(d$year))

  weight_nereo_fit <- kb_fit_weight_nereo(
    d,
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L,
    # Lets these short chains converge without growing the stored objects.
    control = list(adapt_delta = 0.999)
  )

  saveRDS(weight_nereo_fit, "tests/testthat/fixtures/weight_nereo_fit.rds")
  message("Wrote tests/testthat/fixtures/weight_nereo_fit.rds")

  dm <- subset(
    data_weight_sim_macro,
    site %in%
      levels(data_weight_sim_macro$site)[1:4] &
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
    # Lets these short chains converge without growing the stored objects.
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
  # No grouping factors to subset by.
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

if ("carbon" %in% selected) {
  # No grouping factors to subset by.
  carbon_nereo_fit <- kb_fit_carbon_nereo(
    data_carbon_sim_nereo[1:80, ],
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L
  )
  saveRDS(carbon_nereo_fit, "tests/testthat/fixtures/carbon_nereo_fit.rds")
  message("Wrote tests/testthat/fixtures/carbon_nereo_fit.rds")

  carbon_macro_fit <- kb_fit_carbon_macro(
    data_carbon_sim_macro[1:80, ],
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L
  )
  saveRDS(carbon_macro_fit, "tests/testthat/fixtures/carbon_macro_fit.rds")
  message("Wrote tests/testthat/fixtures/carbon_macro_fit.rds")
}

if ("cover_biomass" %in% selected) {
  cover_biomass_nereo_fit <- kb_fit_cover_biomass_nereo(
    size_subset(data_cover_biomass_sim_nereo),
    size_subset(data_plot_biomass_sim_nereo),
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L
  )
  saveRDS(cover_biomass_nereo_fit, "tests/testthat/fixtures/cover_biomass_nereo_fit.rds")
  message("Wrote tests/testthat/fixtures/cover_biomass_nereo_fit.rds")

  cover_biomass_macro_fit <- kb_fit_cover_biomass_macro(
    size_subset(data_cover_biomass_sim_macro),
    size_subset(data_plot_biomass_sim_macro),
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L
  )
  saveRDS(cover_biomass_macro_fit, "tests/testthat/fixtures/cover_biomass_macro_fit.rds")
  message("Wrote tests/testthat/fixtures/cover_biomass_macro_fit.rds")
}
