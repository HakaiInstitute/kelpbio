test_that("kb_priors_weight returns the default named prior list matching the analysis model", {
  p <- kb_priors_weight_nereo()
  expect_named(
    p,
    c(
      "intercept",
      "diameter",
      "diameter2",
      "sd_site",
      "sd_site_diameter",
      "sd_site_year",
      "sd_residual"
    )
  )
  # each expect_equal below also pins the class, so no separate class checks
  expect_equal(p$intercept, kb_prior_normal(0, 2))
  expect_equal(p$diameter, kb_prior_normal(2, 1))
  expect_equal(p$diameter2, kb_prior_normal(0, 0.5))
  expect_equal(p$sd_site, kb_prior_exponential(1))
  expect_equal(p$sd_site_diameter, kb_prior_exponential(1))
  expect_equal(p$sd_site_year, kb_prior_exponential(1))
  expect_equal(p$sd_residual, kb_prior_exponential(1))
})
