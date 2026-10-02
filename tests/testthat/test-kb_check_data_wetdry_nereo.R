test_that("valid nereo wet/dry data passes invisibly", {
  data <- data.frame(wet_mass_g = c(12.4, 58.7), dry_mass_g = c(1.1, 5.0))
  expect_silent(kb_check_data_wetdry_nereo(data))
  expect_identical(kb_check_data_wetdry_nereo(data), data)
})

test_that("missing columns, bad masses, and a dry mass not below the wet mass error", {
  good <- data.frame(wet_mass_g = 4, dry_mass_g = 0.4)
  expect_snapshot(kb_check_data_wetdry_nereo(good["wet_mass_g"]), error = TRUE)
  bad <- good
  bad$dry_mass_g <- 0
  expect_snapshot(kb_check_data_wetdry_nereo(bad), error = TRUE)
  bad$dry_mass_g <- 4
  expect_snapshot(kb_check_data_wetdry_nereo(bad), error = TRUE)
  bad <- good
  bad$wet_mass_g <- NA_real_
  expect_error(kb_check_data_wetdry_nereo(bad), "missing")
})

test_that("masses in milligrams warn", {
  data <- data.frame(wet_mass_g = c(4000, 5000), dry_mass_g = c(400, 450))
  expect_warning(kb_check_data_wetdry_nereo(data), "wet_mass_g")
})
