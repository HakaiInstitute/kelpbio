test_that("fitted returns an estimate/lower/upper tibble matching augment", {
  f <- fitted(weight_fit)
  expect_s3_class(f, "tbl_df")
  expect_named(f, c("estimate", "lower", "upper"))
  expect_equal(nrow(f), nobs(weight_fit))
  expect_true(all(is.finite(f$estimate)))
  expect_true(all(f$estimate > 0))
  expect_true(all(f$lower <= f$estimate & f$estimate <= f$upper))
  expect_equal(f$estimate, augment(weight_fit)$fitted)
})

test_that("fitted conf_level widens the interval", {
  narrow <- fitted(weight_fit, conf_level = 0.5)
  wide <- fitted(weight_fit, conf_level = 0.95)
  expect_true(all(wide$upper - wide$lower >= narrow$upper - narrow$lower))
})

test_that("fitted rejects a non-fit and extra args", {
  expect_error(fitted.kb_fit_weight(1))
  expect_error(fitted(weight_fit, foo = 1))
})
