test_that("fit_weight_sim_macro is a kb_fit_weight the accessors operate on", {
  expect_s3_class(fit_weight_sim_macro, "kb_fit_weight_macro")
  expect_s3_class(fit_weight_sim_macro, "kb_fit_weight")
  expect_s3_class(fit_weight_sim_macro, "kb_fit")
  expect_identical(fit_weight_sim_macro$meta$species, "macrocystis")
  expect_true(nobs(fit_weight_sim_macro) > 0L)
  expect_s3_class(tidy(fit_weight_sim_macro), "tbl_df")
  expect_s3_class(
    kb_predict_weight_by(fit_weight_sim_macro, by = "site"),
    "kb_predictions"
  )
})
