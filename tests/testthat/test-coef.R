test_that("coef is a pure wrapper on tidy", {
  expect_identical(coef(weight_nereo_fit), tidy(weight_nereo_fit))
  expect_identical(
    coef(weight_nereo_fit, conf_level = 0.9),
    tidy(weight_nereo_fit, conf_level = 0.9)
  )
})
