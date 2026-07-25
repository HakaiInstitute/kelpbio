test_that("fit_weight_sim_nereo is a kb_fit_weight the accessors operate on", {
  expect_s3_class(fit_weight_sim_nereo, "kb_fit_weight")
  expect_s3_class(fit_weight_sim_nereo, "kb_fit")
  expect_true(nobs(fit_weight_sim_nereo) > 0L)
  expect_s3_class(tidy(fit_weight_sim_nereo), "tbl_df")
  expect_s3_class(
    kb_predict_weight_by(fit_weight_sim_nereo, by = "site"),
    "kb_predictions"
  )
})
