test_that("tidy returns population terms and SDs", {
  t <- tidy(weight_fit)
  expect_s3_class(t, "tbl_df")
  expect_setequal(t$term, c("bWeight30", "bDiameter", "bDiameter2", "sSite", "sSiteDiameter", "sSiteYear", "sWeight"))
  expect_named(t, c("term", "estimate", "std.error", "conf.low", "conf.high"))
  expect_true(all(t$conf.low <= t$estimate & t$estimate <= t$conf.high))
})
