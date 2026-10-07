test_that("kb_priors_cover_biomass_macro returns the default named prior list matching the analysis model", {
  p <- kb_priors_cover_biomass_macro()
  expect_named(
    p,
    c("cover_slope", "biomass_floor", "tide_height_slope", "error_scaling", "sd_site", "sd_year")
  )
  expect_equal(p$cover_slope, kb_prior_lognormal(2, 1))
  expect_equal(p$biomass_floor, kb_prior_normal(0.4, 0.3))
  expect_equal(p$tide_height_slope, kb_prior_normal(0.227, 0.03))
  expect_equal(p$error_scaling, kb_prior_normal(1, 0.5))
  expect_equal(p$sd_site, kb_prior_exponential(1))
  expect_equal(p$sd_year, kb_prior_exponential(1))
})
