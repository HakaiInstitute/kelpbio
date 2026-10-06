test_that("kb_priors_cover_biomass_macro returns the default named prior list matching the analysis model", {
  p <- kb_priors_cover_biomass_macro()
  expect_named(
    p,
    c("canopy", "floor", "tide", "scaling", "sd_site", "sd_year")
  )
  expect_equal(p$canopy, kb_prior_normal(2, 1))
  expect_equal(p$floor, kb_prior_normal(0.4, 0.3))
  expect_equal(p$tide, kb_prior_normal(0.227, 0.03))
  expect_equal(p$scaling, kb_prior_normal(1, 0.5))
  expect_equal(p$sd_site, kb_prior_exponential(1))
  expect_equal(p$sd_year, kb_prior_exponential(1))
})
