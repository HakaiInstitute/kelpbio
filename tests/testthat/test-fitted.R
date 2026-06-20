test_that("fitted returns a positive response-scale vector matching augment", {
  f <- fitted(weight_fit)
  expect_type(f, "double")
  expect_length(f, nobs(weight_fit))
  expect_true(all(is.finite(f)))
  expect_true(all(f > 0))
  expect_equal(f, augment(weight_fit)$fitted)
})

test_that("fitted rejects a non-fit and extra args", {
  expect_error(fitted.kb_fit_weight(1))
  expect_error(fitted(weight_fit, foo = 1))
})
