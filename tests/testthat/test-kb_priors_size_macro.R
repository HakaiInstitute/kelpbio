test_that("kb_priors_size_macro returns the default named prior list matching the analysis model", {
  p <- kb_priors_size_macro()
  expect_named(
    p,
    c("intercept", "dispersion", "sd_site", "sd_year", "sd_site_year")
  )
  expect_equal(p$intercept, kb_prior_normal(0, 2))
  expect_equal(p$dispersion, kb_prior_exponential(1))
  expect_equal(p$sd_site, kb_prior_exponential(1))
  expect_equal(p$sd_year, kb_prior_exponential(1))
  expect_equal(p$sd_site_year, kb_prior_exponential(1))
})
