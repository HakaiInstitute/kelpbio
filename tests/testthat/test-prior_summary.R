test_that("prior_summary returns the resolved priors", {
  ps <- prior_summary(weight_fit)
  expect_type(ps, "list")
  expect_true(all(
    c(
      "intercept",
      "power",
      "floor",
      "nu",
      "sd_site",
      "sd_year",
      "sd_site_power",
      "sd_site_year",
      "sd_residual"
    ) %in%
      names(ps)
  ))
  expect_s3_class(ps$intercept, "kb_prior")
})
