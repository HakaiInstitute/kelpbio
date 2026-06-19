test_that("converged returns a logical and honours rhat/esr thresholds", {
  expect_type(converged(weight_fit), "logical")
  expect_true(converged(weight_fit, rhat = Inf, esr = 0))
  expect_false(converged(weight_fit, rhat = 1, esr = Inf))
})
