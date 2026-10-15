test_that("prior_summary returns the resolved priors", {
  ps <- prior_summary(weight_nereo_fit)
  expect_type(ps, "list")
  expect_named(ps, names(kb_priors_weight_nereo()))
  expect_s3_class(ps$intercept, "kb_prior")
})
