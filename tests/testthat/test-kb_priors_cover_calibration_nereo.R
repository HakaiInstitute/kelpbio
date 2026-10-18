test_that("kb_priors_cover_calibration_nereo returns the default named prior list matching the analysis model", {
  p <- kb_priors_cover_calibration_nereo()
  expect_named(
    p,
    c(
      "cover_slope", "biomass_floor", "tide_height_slope", "sd_residual",
      "cv_residual", "sd_site", "sd_year"
    )
  )
  expect_equal(p$cover_slope, kb_prior_lognormal(2, 1))
  expect_equal(p$biomass_floor, kb_prior_normal(0, 0.1))
  expect_equal(p$tide_height_slope, kb_prior_normal(0.276, 0.04))
  expect_equal(p$sd_residual, kb_prior_exponential(2))
  expect_equal(p$cv_residual, kb_prior_normal(0, 1))
  expect_equal(p$sd_site, kb_prior_exponential(1))
  expect_equal(p$sd_year, kb_prior_exponential(1))
})
