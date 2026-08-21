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
  expect_error(residuals.kb_fit(1), "kb_fit")
  expect_error(
    residuals(weight_fit, type = "pearson"),
    class = "rlib_error_dots_nonempty"
  )
})

test_that("the internal generic's default aborts for a fit with no method", {
  # The only guard once the public method accepts any kb_fit.
  expect_error(.deviance(structure(list(), class = c("kb_fit_other", "kb_fit")), 1), "no method for a <kb_fit_other>")
})
