test_that("nitrogen_fraction converts micrograms of nitrogen per milligram of sample", {
  data <- data.frame(sample_mass_mg = c(2.5, 2), nitrogen_mass_ug = c(50, 40))
  expect_equal(nitrogen_fraction(data), c(0.02, 0.02))
})
