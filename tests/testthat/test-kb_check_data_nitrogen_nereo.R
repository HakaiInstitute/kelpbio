test_that("valid nereo nitrogen data passes invisibly", {
  data <- data.frame(sample_mass_mg = c(2.5, 2.3), nitrogen_mass_ug = c(48, 41))
  expect_silent(kb_check_data_nitrogen_nereo(data))
  expect_identical(kb_check_data_nitrogen_nereo(data), data)
})

test_that("a missing column, a zero mass, and nitrogen above the sample mass error", {
  good <- data.frame(sample_mass_mg = 2.5, nitrogen_mass_ug = 48)
  expect_snapshot(kb_check_data_nitrogen_nereo(good["sample_mass_mg"]), error = TRUE)
  bad <- good
  bad$nitrogen_mass_ug <- 0
  expect_snapshot(kb_check_data_nitrogen_nereo(bad), error = TRUE)
  # a sample mass in grams makes the nitrogen exceed it
  bad <- good
  bad$sample_mass_mg <- 0.0025
  expect_snapshot(kb_check_data_nitrogen_nereo(bad), error = TRUE)
  bad <- good
  bad$sample_mass_mg <- NA_real_
  expect_error(kb_check_data_nitrogen_nereo(bad), "missing")
})

test_that("an implausible nitrogen fraction warns and the data still pass", {
  data <- data.frame(sample_mass_mg = c(2.5, 2.5), nitrogen_mass_ug = c(48, 200))
  expect_warning(
    out <- kb_check_data_nitrogen_nereo(data),
    "1 sample in `data` has a nitrogen fraction outside 0.002 to 0.05"
  )
  expect_identical(out, data)
})

test_that("x_name must be a string", {
  expect_error(kb_check_data_nitrogen_nereo(data.frame(), x_name = 1), "x_name")
})
