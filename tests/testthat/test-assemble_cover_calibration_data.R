calibration_rows <- function() {
  survey_calibration_rows(survey_biomass(), progress = "none")
}

test_that("assemble_cover_calibration_data maps data to the Stan data block", {
  d <- calibration_rows()
  sd <- assemble_cover_calibration_data(d, kb_priors_cover_calibration_nereo())
  expect_equal(sd$n_obs, 3L)
  expect_equal(sd$canopy_area_m2, d$canopy_area_m2)
  expect_equal(sd$plot_area_m2, d$plot_area_m2)
  expect_equal(sd$tide_height_m, d$tide_height_m)
  expect_equal(sd$biomass, d$biomass_kg_m2)
  expect_equal(sd$biomass_sd, d$biomass_sd_kg_m2)
  expect_equal(sd$zero, c(0L, 1L, 0L))
  expect_equal(sd$prior_only, 0L)
})

test_that("assemble_cover_calibration_data accepts zero-row data", {
  sd <- assemble_cover_calibration_data(
    calibration_rows()[0, ],
    kb_priors_cover_calibration_nereo(),
    prior_only = TRUE
  )
  expect_equal(sd$n_obs, 0L)
  expect_length(sd$biomass, 0)
  expect_length(sd$zero, 0)
  expect_equal(sd$prior_only, 1L)
})
