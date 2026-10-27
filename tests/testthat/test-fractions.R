test_that("carbon_fraction converts micrograms of carbon per milligram of sample", {
  data <- data.frame(sample_mass_mg = c(2.5, 2), carbon_mass_ug = c(650, 620))
  expect_equal(carbon_fraction(data), c(0.26, 0.31))
})

test_that("nitrogen_fraction converts micrograms of nitrogen per milligram of sample", {
  data <- data.frame(sample_mass_mg = c(2.5, 2), nitrogen_mass_ug = c(50, 40))
  expect_equal(nitrogen_fraction(data), c(0.02, 0.02))
})
