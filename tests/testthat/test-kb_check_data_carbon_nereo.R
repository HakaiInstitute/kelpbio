test_that("valid nereo carbon data passes invisibly", {
  data <- data.frame(sample_mass_mg = c(2.5, 2.3), carbon_mass_ug = c(650, 610))
  expect_silent(kb_check_data_carbon_nereo(data))
  expect_identical(kb_check_data_carbon_nereo(data), data)
})

test_that("a missing column, a zero mass, and carbon above the sample mass error", {
  good <- data.frame(sample_mass_mg = 2.5, carbon_mass_ug = 650)
  expect_snapshot(kb_check_data_carbon_nereo(good["sample_mass_mg"]), error = TRUE)
  bad <- good
  bad$carbon_mass_ug <- 0
  expect_snapshot(kb_check_data_carbon_nereo(bad), error = TRUE)
  # a sample mass in grams makes the carbon exceed it
  bad <- good
  bad$sample_mass_mg <- 0.0025
  expect_snapshot(kb_check_data_carbon_nereo(bad), error = TRUE)
  bad <- good
  bad$sample_mass_mg <- NA_real_
  expect_error(kb_check_data_carbon_nereo(bad), "missing")
})

test_that("an implausible carbon fraction warns and the data still pass", {
  data <- data.frame(sample_mass_mg = c(2.5, 2.5), carbon_mass_ug = c(650, 1500))
  expect_warning(
    out <- kb_check_data_carbon_nereo(data),
    "1 sample in `data` has a carbon fraction outside 0.10 to 0.50"
  )
  expect_identical(out, data)
})
