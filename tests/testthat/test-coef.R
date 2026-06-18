test_that("coef returns group-level terms", {
  cf <- coef(weight_fit)
  expect_s3_class(cf, "tbl_df")
  expect_true(all(grepl("^bSite\\[|^bSiteDiameter\\[|^bSiteYear\\[", cf$term)))
  expect_true(all(c("estimate", "conf.low", "conf.high") %in% names(cf)))
})
