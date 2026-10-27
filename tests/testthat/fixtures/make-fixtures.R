# Builds the cached test fixtures; not run during testing. From the package
# root, optionally naming models to rebuild only those:
#   Rscript tests/testthat/fixtures/make-fixtures.R size wetdry

devtools::load_all(quiet = TRUE)

models <- c("weight", "size", "wetdry", "carbon", "nitrogen", "cover_calibration")
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
      as.character(year) %in% c("2019", "2020", "2021")
  )
  dm$site <- droplevels(factor(dm$site))

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
    size_subset(data_size_sample_sim_nereo),
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

if ("nitrogen" %in% selected) {
  # No grouping factors to subset by.
  nitrogen_nereo_fit <- kb_fit_nitrogen_nereo(
    data_nitrogen_sim_nereo[1:80, ],
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L
  )
  saveRDS(nitrogen_nereo_fit, "tests/testthat/fixtures/nitrogen_nereo_fit.rds")
  message("Wrote tests/testthat/fixtures/nitrogen_nereo_fit.rds")

  nitrogen_macro_fit <- kb_fit_nitrogen_macro(
    data_nitrogen_sim_macro[1:80, ],
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L
  )
  saveRDS(nitrogen_macro_fit, "tests/testthat/fixtures/nitrogen_macro_fit.rds")
  message("Wrote tests/testthat/fixtures/nitrogen_macro_fit.rds")
}

if ("cover_calibration" %in% selected) {
  # Survey biomass at four sites from the bundled weight and size pre-fits.
  survey_subset <- function(data) {
    d <- subset(data, site %in% levels(data$site)[1:4])
    d$site <- droplevels(factor(d$site))
    d
  }
  set.seed(42)
  biomass_nereo <- kb_predict_biomass_in_situ(
    fit_weight_sim_nereo,
    fit_size_sim_nereo,
    survey_subset(data_in_situ_sim_nereo),
    progress = "none"
  )
  cover_calibration_nereo_fit <- kb_fit_cover_calibration_nereo(
    biomass_nereo,
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L,
    control = list(adapt_delta = 0.99)
  )
  saveRDS(cover_calibration_nereo_fit, "tests/testthat/fixtures/cover_calibration_nereo_fit.rds")
  message("Wrote tests/testthat/fixtures/cover_calibration_nereo_fit.rds")

  set.seed(42)
  survey_macro <- survey_subset(data_in_situ_sim_macro)
  size_census <- subset(
    data_size_census_sim_macro,
    survey_id %in% survey_macro$survey_id
  )
  biomass_macro <- kb_predict_biomass_in_situ(
    fit_weight_sim_macro,
    size_census,
    survey_macro,
    progress = "none"
  )
  cover_calibration_macro_fit <- kb_fit_cover_calibration_macro(
    biomass_macro,
    chains = 2L,
    niters = 300L,
    nthin = 5L,
    cores = 2L,
    progress = "none",
    seed = 42L,
    control = list(adapt_delta = 0.99)
  )
  saveRDS(cover_calibration_macro_fit, "tests/testthat/fixtures/cover_calibration_macro_fit.rds")
  message("Wrote tests/testthat/fixtures/cover_calibration_macro_fit.rds")
}
