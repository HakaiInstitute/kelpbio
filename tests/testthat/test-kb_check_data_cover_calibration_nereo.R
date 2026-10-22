test_that("valid nereo calibration data passes invisibly, including zero canopy and biomass", {
  data <- survey_biomass()
  expect_silent(kb_check_data_cover_calibration_nereo(data))
  expect_identical(kb_check_data_cover_calibration_nereo(data), data)
})

test_that("rows without drone cover and extra columns pass", {
  data <- survey_biomass()
  data[2, c("plot_area_m2", "canopy_area_m2", "tide_height_m")] <- NA
  data$region <- "north"
  expect_silent(kb_check_data_cover_calibration_nereo(data))
})

test_that("data without biomass draws errors, pointing to kb_predict_biomass_in_situ()", {
  data <- survey_biomass()
  expect_snapshot(
    kb_check_data_cover_calibration_nereo(data[setdiff(names(data), "biomass_kg_m2")]),
    error = TRUE
  )
  data$biomass_kg_m2 <- c(2.8, 0, 6)
  expect_snapshot(kb_check_data_cover_calibration_nereo(data), error = TRUE)
})

test_that("bad drone columns error naming the column", {
  good <- survey_biomass()
  bad <- good
  bad$canopy_area_m2[1] <- 250
  expect_error(kb_check_data_cover_calibration_nereo(bad), "canopy_area_m2")
  bad <- good
  bad$tide_height_m[1] <- NA
  expect_error(kb_check_data_cover_calibration_nereo(bad), "tide_height_m")
  bad <- good
  bad$site[1] <- NA
  expect_error(kb_check_data_cover_calibration_nereo(bad), "site")
  expect_error(
    kb_check_data_cover_calibration_nereo(good[setdiff(names(good), "plot_area_m2")]),
    "plot_area_m2"
  )
})

test_that("a tide height in centimetres warns", {
  data <- survey_biomass()
  data$tide_height_m <- c(50, 120, 80)
  expect_warning(kb_check_data_cover_calibration_nereo(data), "tide_height_m")
})

test_that("x_name must be a string", {
  expect_error(kb_check_data_cover_calibration_nereo(data.frame(), x_name = 1), "x_name")
})

test_that("summed survey biomass errors, pointing to the defaults", {
  summed <- survey_biomass()[c("site", "year", "biomass_kg_m2")]
  expect_error(kb_check_data_cover_calibration_nereo(summed), "kb_predict_biomass_in_situ")
})
