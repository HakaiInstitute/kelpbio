test_that("kb_priors_weight returns the default named prior list matching the analysis model", {
  p <- kb_priors_weight_nereo()
  expect_named(
    p,
    c(
      "intercept",
      "log_power",
      "floor",
      "nu",
      "sd_site",
      "sd_year",
      "sd_site_power",
      "sd_site_year",
      "sd_residual"
    )
  )
  # each expect_equal below also pins the class, so no separate class checks
  expect_equal(p$intercept, kb_prior_normal(0, 2))
  expect_equal(p$log_power, kb_prior_normal(0.693, 0.5))
  expect_equal(p$floor, kb_prior_beta(1, 5))
  expect_equal(p$nu, kb_prior_gamma(2, 0.1))
  expect_equal(p$sd_site, kb_prior_exponential(1))
  expect_equal(p$sd_year, kb_prior_exponential(1))
  expect_equal(p$sd_site_power, kb_prior_exponential(1))
  expect_equal(p$sd_site_year, kb_prior_exponential(1))
  expect_equal(p$sd_residual, kb_prior_exponential(1))
})
