test_that("fitted returns a positive, finite response-scale vector", {
  f <- fitted(weight_fit)
  expect_type(f, "double")
  expect_length(f, nobs(weight_fit))
  expect_true(all(is.finite(f)))
  expect_true(all(f > 0))
})

test_that("fitted rejects a non-fit and extra args", {
  expect_error(fitted.kb_fit_weight(1), "kb_fit_weight")
  expect_error(fitted(weight_fit, foo = 1), class = "rlib_error_dots_nonempty")
})
