test_that("glance returns a one-row summary with bboutools columns", {
  g <- glance(weight_fit)
  expect_equal(nrow(g), 1L)
  expect_named(g, c("n", "K", "nchains", "niters", "nthin", "ess", "rhat", "converged"))
  expect_type(g$converged, "logical")
  expect_equal(g$n, nobs(weight_fit))
  expect_equal(g$K, npars(weight_fit))
})

test_that("glance's converged column agrees with converged()", {
  # Guard against tibble() data-masking the rhat/esr thresholds to the columns.
  expect_equal(glance(weight_fit)$converged, converged(weight_fit))
  expect_equal(
    glance(weight_fit, rhat = 1.001, esr = 0.5)$converged,
    converged(weight_fit, rhat = 1.001, esr = 0.5)
  )
})
