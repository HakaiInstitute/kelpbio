test_that("coef is a pure wrapper on tidy", {
  # identity to tidy() implies the class and the column names
  expect_identical(coef(weight_fit), tidy(weight_fit))
  expect_identical(
    coef(weight_fit, conf_level = 0.9),
    tidy(weight_fit, conf_level = 0.9)
  )
})
