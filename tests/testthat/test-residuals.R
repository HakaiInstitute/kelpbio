test_that("residuals returns an estimate/lower/upper tibble matching augment", {
  r <- residuals(weight_fit)
  expect_s3_class(r, "tbl_df")
  expect_named(r, c("estimate", "lower", "upper"))
  expect_equal(nrow(r), nobs(weight_fit))
  expect_true(all(is.finite(r$estimate)))
  expect_true(all(r$lower <= r$estimate & r$estimate <= r$upper))
  expect_equal(r$estimate, augment(weight_fit)$residual)
})

test_that("residuals are deviance, not raw response residuals", {
  a <- augment(weight_fit)
  expect_false(isTRUE(all.equal(a$residual, a$weight - a$fitted)))
})

test_that("residuals rejects a non-fit and extra args", {
  expect_error(residuals.kb_fit_weight(1))
  expect_error(residuals(weight_fit, type = "pearson"))
})
