test_that("kb_priors_wetdry_macro returns the default named prior list matching the analysis model", {
  p <- kb_priors_wetdry_macro()
  expect_named(p, c("intercept", "precision"))
  expect_equal(p$intercept, kb_prior_normal(0, 2))
  expect_equal(p$precision, kb_prior_exponential(0.01))
})
