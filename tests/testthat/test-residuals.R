test_that("residuals returns a finite deviance-residual vector", {
  r <- residuals(weight_fit)
  expect_type(r, "double")
  expect_length(r, nobs(weight_fit))
  expect_true(all(is.finite(r)))
})

test_that("residuals are deviance, not raw response residuals", {
  a <- augment(weight_fit)
  expect_false(isTRUE(all.equal(a$residual, a$weight - a$fitted)))
})

test_that("macro residuals are finite Gamma deviance residuals matching augment", {
  r <- residuals(weight_macro_fit)
  expect_type(r, "double")
  expect_length(r, nobs(weight_macro_fit))
  expect_true(all(is.finite(r)))
  a <- augment(weight_macro_fit)
  expect_equal(a$residual, r)
  # deviance, not raw response residuals
  expect_false(isTRUE(all.equal(a$residual, a$weight - a$fitted)))
})

test_that("residuals rejects a non-fit and extra args", {
  expect_error(residuals.kb_fit_weight(1), "kb_fit_weight")
  expect_error(
    residuals(weight_fit, type = "pearson"),
    class = "rlib_error_dots_nonempty"
  )
})
