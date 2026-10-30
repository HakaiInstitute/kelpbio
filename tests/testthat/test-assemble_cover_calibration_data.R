calibration_rows <- function() {
  survey_calibration_rows(survey_biomass(), progress = "none")
}

test_that("assemble_cover_calibration_data maps data to the Stan data block", {
  d <- calibration_rows()
  sd <- assemble_cover_calibration_data(d, kb_priors_cover_calibration_nereo())
  expect_equal(sd$n_obs, 3L)
  expect_equal(sd$canopy_area_m2, d$canopy_area_m2)
  expect_equal(sd$plot_area_m2, d$plot_area_m2)
  expect_equal(sd$canopy_tide_height_m, d$canopy_tide_height_m)
  expect_equal(sd$biomass, d$biomass_kg_m2)
  expect_equal(sd$weight_cv, c(d$biomass_sd_kg_m2[1] / d$biomass_kg_m2[1], 0, d$biomass_sd_kg_m2[3] / d$biomass_kg_m2[3]))
  expect_equal(sd$zero, c(0L, 1L, 0L))
  expect_equal(sd$presence_on, 0L)
  expect_equal(sd$prior_only, 0L)
  sd <- assemble_cover_calibration_data(d, kb_priors_cover_calibration_nereo(), presence_on = TRUE)
  expect_equal(sd$presence_on, 1L)
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
