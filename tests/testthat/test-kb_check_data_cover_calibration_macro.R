test_that("valid macro calibration data passes invisibly, including zero canopy and biomass", {
  data <- survey_biomass()
  expect_silent(kb_check_data_cover_calibration_macro(data))
  expect_identical(kb_check_data_cover_calibration_macro(data), data)
})

test_that("errors name kb_check_data_cover_calibration_macro()", {
  data <- survey_biomass()
  expect_snapshot(
    kb_check_data_cover_calibration_macro(data[setdiff(names(data), "biomass_kg_m2")]),
    error = TRUE
  )
})

test_that("x_name must be a string", {
  expect_error(kb_check_data_cover_calibration_macro(data.frame(), x_name = 1), "x_name")
})
