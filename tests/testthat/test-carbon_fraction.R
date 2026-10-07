test_that("carbon_fraction converts micrograms of carbon per milligram of sample", {
  data <- data.frame(sample_mass_mg = c(2.5, 2), carbon_mass_ug = c(650, 620))
  expect_equal(carbon_fraction(data), c(0.26, 0.31))
})
