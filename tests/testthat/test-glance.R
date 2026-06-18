test_that("glance returns a one-row summary", {
  g <- glance(weight_fit)
  expect_equal(nrow(g), 1L)
  expect_named(g, c("nobs", "nchains", "niters", "npars", "converged"))
  expect_type(g$converged, "logical")
})
