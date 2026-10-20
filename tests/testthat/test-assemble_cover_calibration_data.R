calibration_rows <- function() {
  survey_calibration_rows(survey_biomass(), progress = "none")
}

test_that("assemble_cover_calibration_data maps data to the Stan data block", {
  d <- calibration_rows()
  sd <- assemble_cover_calibration_data(d, kb_priors_cover_calibration_nereo())
  expect_equal(sd$n_obs, 3L)
  expect_equal(sd$n_site, 2L)
  expect_equal(sd$n_year, 2L)
  expect_equal(sd$site, c(1L, 2L, 1L))
  expect_equal(sd$year, c(1L, 1L, 2L))
  expect_equal(sd$canopy_area_m2, d$canopy_area_m2)
  expect_equal(sd$plot_area_m2, d$plot_area_m2)
  expect_equal(sd$tide_height_m, d$tide_height_m)
  expect_equal(sd$biomass, d$biomass_kg_m2)
  expect_equal(sd$biomass_sd, d$biomass_sd_kg_m2)
  expect_equal(sd$zero, c(0L, 1L, 0L))
  expect_equal(sd$prior_only, 0L)
})

test_that("assemble_cover_calibration_data maps every prior hyperparameter to its own Stan field", {
  priors <- list(
    cover_slope = kb_prior_lognormal(0.1, 1.1),
    biomass_floor = kb_prior_normal(0.2, 1.2),
    tide_height_slope = kb_prior_normal(0.3, 1.3),
    sd_residual = kb_prior_exponential(2.3),
    cv_residual = kb_prior_normal(0.4, 1.4),
    sd_site = kb_prior_exponential(2.1),
    sd_year = kb_prior_exponential(2.2)
  )
  sd <- assemble_cover_calibration_data(calibration_rows(), priors)
  expect_equal(sd$prior_cover_slope_meanlog, 0.1)
  expect_equal(sd$prior_cover_slope_sdlog, 1.1)
  expect_equal(sd$prior_biomass_floor_mean, 0.2)
  expect_equal(sd$prior_biomass_floor_sd, 1.2)
  expect_equal(sd$prior_tide_height_slope_mean, 0.3)
  expect_equal(sd$prior_tide_height_slope_sd, 1.3)
  expect_equal(sd$prior_sd_residual_rate, 2.3)
  expect_equal(sd$prior_cv_residual_mean, 0.4)
  expect_equal(sd$prior_cv_residual_sd, 1.4)
  expect_equal(sd$prior_sd_site_rate, 2.1)
  expect_equal(sd$prior_sd_year_rate, 2.2)
})

test_that("assemble_cover_calibration_data accepts zero-row data", {
  sd <- assemble_cover_calibration_data(
    calibration_rows()[0, ],
    kb_priors_cover_calibration_nereo(),
    prior_only = TRUE
  )
  expect_equal(sd$n_obs, 0L)
  expect_equal(sd$n_site, 1L)
  expect_length(sd$biomass, 0)
  expect_length(sd$zero, 0)
  expect_equal(sd$prior_only, 1L)
})
