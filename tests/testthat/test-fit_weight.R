test_that("fit_weight is a kb_fit_weight the accessors operate on", {
  expect_s3_class(fit_weight, "kb_fit_weight")
  expect_s3_class(fit_weight, "kb_fit")
  expect_true(nobs(fit_weight) > 0L)
  expect_s3_class(tidy(fit_weight), "tbl_df")
  expect_s3_class(kb_predict_weight_by(fit_weight, by = "site"), "kb_predictions")
})
