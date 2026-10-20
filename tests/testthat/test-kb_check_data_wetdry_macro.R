test_that("valid macro wet/dry data passes invisibly", {
  data <- data.frame(wet_mass_g = c(1.8, 4.6), dry_mass_g = c(0.22, 0.57))
  expect_silent(kb_check_data_wetdry_macro(data))
  expect_identical(kb_check_data_wetdry_macro(data), data)
})

test_that("errors name kb_check_data_wetdry_macro()", {
  good <- data.frame(wet_mass_g = 4, dry_mass_g = 0.4)
  expect_snapshot(kb_check_data_wetdry_macro(good["wet_mass_g"]), error = TRUE)
})

test_that("x_name must be a string", {
  expect_error(kb_check_data_wetdry_macro(data.frame(), x_name = 1), "x_name")
})
