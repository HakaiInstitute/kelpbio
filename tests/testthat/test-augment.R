test_that("augment appends fitted and residual columns matching the methods", {
  a <- augment(weight_fit)
  expect_true(all(c("fitted", "residual") %in% names(a)))
  expect_false(any(c("lower", "upper") %in% names(a)))
  expect_equal(nrow(a), nrow(weight_fit$data))
  # fitted/residual come straight from the methods (no drift); residual is the
  # deviance residual, not weight - fitted.
  expect_equal(a$fitted, fitted(weight_fit))
  expect_equal(a$residual, residuals(weight_fit))
})
