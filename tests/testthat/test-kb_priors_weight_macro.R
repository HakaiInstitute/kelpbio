test_that("kb_priors_weight_macro returns the default named prior list matching the analysis model", {
  p <- kb_priors_weight_macro()
  expect_named(
    p,
    c(
      "intercept",
      "fronds",
      "shape",
      "sd_site",
      "sd_year",
      "sd_site_year"
    )
  )
  # each expect_equal below also pins the class, so no separate class checks
  expect_equal(p$intercept, kb_prior_normal(0, 2))
  expect_equal(p$fronds, kb_prior_normal(1, 0.5))
  expect_equal(p$shape, kb_prior_exponential(0.1))
  expect_equal(p$sd_site, kb_prior_exponential(1))
  expect_equal(p$sd_year, kb_prior_exponential(1))
  expect_equal(p$sd_site_year, kb_prior_exponential(1))
})
