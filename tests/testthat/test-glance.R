test_that("glance returns a one-row summary with bboutools columns", {
  g <- glance(weight_fit)
  expect_equal(nrow(g), 1L)
  expect_named(g, c("n", "K", "nchains", "niters", "nthin", "ess", "rhat", "converged"))
  expect_type(g$converged, "logical")
  expect_equal(g$n, nobs(weight_fit))
  expect_equal(g$K, npars(weight_fit))
})
