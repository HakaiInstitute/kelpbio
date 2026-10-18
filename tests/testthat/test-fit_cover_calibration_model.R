test_that("fit_cover_calibration_model builds a fit from the species' check and defaults", {
  local_fit_stan_stub(cover_calibration_nereo_fit)
  fit <- fit_cover_calibration_model(
    calibration_input(cover_calibration_nereo_fit),
    priors = NULL,
    species = "nereocystis",
    check_data = kb_check_data_cover_calibration_nereo,
    defaults = kb_priors_cover_calibration_nereo(),
    prior_only = FALSE,
    chains = 2L,
    niters = 100L,
    nthin = 1L,
    cores = 1L,
    seed = NULL,
    progress = "none",
    progress_dir = NULL
  )
  expect_s3_class(fit, "kb_fit_cover_calibration_nereo")
  expect_identical(fit$meta$priors, kb_priors_cover_calibration_nereo())
  expect_identical(
    fit$meta$terms$fixed,
    c(
      "cover_slope", "biomass_floor", "tide_height_slope", "sd_residual",
      "cv_residual", "sd_site", "sd_year"
    )
  )
})

test_that("survey_calibration_rows keeps covered rows as their mean and SD", {
  data <- survey_biomass()
  data[2, c("plot_area_m2", "canopy_area_m2", "tide_height_m")] <- NA
  expect_snapshot(rows <- survey_calibration_rows(data))
  expect_equal(nrow(rows), 2L)
  draws <- posterior::draws_of(data$biomass_kg_m2)
  expect_equal(rows$biomass_kg_m2, colMeans(draws)[c(1, 3)])
  expect_equal(rows$biomass_sd_kg_m2, apply(draws, 2, stats::sd)[c(1, 3)])
  expect_false(posterior::is_rvar(rows$biomass_kg_m2))
  expect_silent(survey_calibration_rows(data, progress = "none"))
})

test_that("calibration data without drone cover errors", {
  data <- survey_biomass()
  data[c("plot_area_m2", "canopy_area_m2", "tide_height_m")] <- NA
  expect_snapshot(
    kb_fit_cover_calibration_nereo(data, progress = "none"),
    error = TRUE
  )
})
