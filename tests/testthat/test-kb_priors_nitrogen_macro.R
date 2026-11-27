test_that("kb_priors_nitrogen_macro returns the default named prior list matching the analysis model", {
  p <- kb_priors_nitrogen_macro()
  expect_named(p, c("intercept", "precision"))
  expect_equal(p$intercept, kb_prior_normal(-3.7, 0.5))
  expect_equal(p$precision, kb_prior_exponential(0.001))
})
