test_that("residuals returns a finite deviance-residual vector matching augment", {
  r <- residuals(weight_fit)
  expect_type(r, "double")
  expect_length(r, nobs(weight_fit))
  expect_true(all(is.finite(r)))
  expect_equal(r, augment(weight_fit)$residual)
})

test_that("residuals are deviance, not raw response residuals", {
  a <- augment(weight_fit)
  expect_false(isTRUE(all.equal(a$residual, a$weight_kg - a$fitted)))
})

test_that("residuals rejects a non-fit and extra args", {
  expect_error(residuals.kb_fit_weight(1))
  expect_error(residuals(weight_fit, type = "pearson"))
})
