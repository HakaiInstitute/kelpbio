test_that("warn_dry_wet_ratio counts samples outside 0.02 to 0.5 and keeps them", {
  ok <- data.frame(wet_mass_g = c(4, 10), dry_mass_g = c(0.4, 0.8))
  expect_no_warning(warn_dry_wet_ratio(ok, "`d`"))
  odd <- data.frame(wet_mass_g = c(4, 4, 4), dry_mass_g = c(0.4, 2.8, 0.04))
  expect_snapshot(out <- warn_dry_wet_ratio(odd, "`d`"))
  expect_identical(out, odd)
})
