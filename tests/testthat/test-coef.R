test_that("coef is a pure wrapper on tidy", {
  cf <- coef(weight_fit)
  expect_s3_class(cf, "tbl_df")
  expect_named(cf, c("term", "estimate", "lower", "upper"))
  expect_identical(cf, tidy(weight_fit))
})
