test_that("valid macro nitrogen data passes invisibly", {
  data <- data.frame(sample_mass_mg = c(2.5, 2.3), nitrogen_mass_ug = c(48, 41))
  expect_silent(kb_check_data_nitrogen_macro(data))
  expect_identical(kb_check_data_nitrogen_macro(data), data)
})

test_that("errors name kb_check_data_nitrogen_macro()", {
  good <- data.frame(sample_mass_mg = 2.5, nitrogen_mass_ug = 48)
  expect_snapshot(kb_check_data_nitrogen_macro(good["sample_mass_mg"]), error = TRUE)
})

test_that("x_name must be a string", {
  expect_error(kb_check_data_nitrogen_macro(data.frame(), x_name = 1), "x_name")
})
