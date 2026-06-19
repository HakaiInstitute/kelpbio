test_that("augment adds fitted/residual/lower/upper at observed rows", {
  a <- augment(weight_fit)
  expect_true(all(c("fitted", "residual", "lower", "upper") %in% names(a)))
  expect_equal(nrow(a), nrow(weight_fit$data))
  expect_true(all(a$lower <= a$fitted & a$fitted <= a$upper))
  expect_true(all(a$fitted > 0))
  expect_equal(a$residual, a$weight - a$fitted)
})
