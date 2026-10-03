test_that("carbon_fraction converts micrograms of carbon per milligram of sample", {
  data <- data.frame(sample_mass_mg = c(2.5, 2), carbon_mass_ug = c(650, 620))
  expect_equal(carbon_fraction(data), c(0.26, 0.31))
})

test_that("warn_carbon_fraction counts samples outside 0.10 to 0.50 and keeps them", {
  ok <- data.frame(sample_mass_mg = c(2, 2), carbon_mass_ug = c(500, 700))
  expect_no_warning(warn_carbon_fraction(ok, "`d`"))
  odd <- data.frame(sample_mass_mg = c(2, 2, 2), carbon_mass_ug = c(500, 1200, 100))
  expect_snapshot(out <- warn_carbon_fraction(odd, "`d`"))
  expect_identical(out, odd)
})
