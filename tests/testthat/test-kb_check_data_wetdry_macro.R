test_that("valid macro wet/dry data passes invisibly", {
  data <- data.frame(wet_mass_g = c(1.8, 4.6), dry_mass_g = c(0.22, 0.57))
  expect_silent(kb_check_data_wetdry_macro(data))
  expect_identical(kb_check_data_wetdry_macro(data), data)
})

test_that("missing columns, bad masses, and a dry mass not below the wet mass error", {
  good <- data.frame(wet_mass_g = 4, dry_mass_g = 0.4)
  expect_snapshot(kb_check_data_wetdry_macro(good["wet_mass_g"]), error = TRUE)
  bad <- good
  bad$dry_mass_g <- 0
  expect_snapshot(kb_check_data_wetdry_macro(bad), error = TRUE)
  bad$dry_mass_g <- 4
  expect_snapshot(kb_check_data_wetdry_macro(bad), error = TRUE)
  bad <- good
  bad$wet_mass_g <- NA_real_
  expect_error(kb_check_data_wetdry_macro(bad), "missing")
})

test_that("masses in milligrams warn", {
  data <- data.frame(wet_mass_g = c(4000, 5000), dry_mass_g = c(400, 450))
  expect_warning(kb_check_data_wetdry_macro(data), "wet_mass_g")
})

test_that("an implausible dry:wet ratio warns and the data still pass", {
  data <- data.frame(wet_mass_g = c(4, 4), dry_mass_g = c(0.4, 2.8))
  expect_warning(
    out <- kb_check_data_wetdry_macro(data),
    "1 sample in `data` has a dry:wet mass ratio outside 0.02 to 0.5"
  )
  expect_identical(out, data)
})
