test_that("fit_wetdry_sim_nereo is a kb_fit_wetdry the accessors operate on", {
  expect_s3_class(fit_wetdry_sim_nereo, "kb_fit_wetdry_nereo")
  expect_s3_class(fit_wetdry_sim_nereo, "kb_fit_wetdry")
  expect_identical(fit_wetdry_sim_nereo$meta$species, "nereocystis")
  expect_true(nobs(fit_wetdry_sim_nereo) > 0L)
  expect_s3_class(tidy(fit_wetdry_sim_nereo), "tbl_df")
  expect_s3_class(kb_predict_wetdry(fit_wetdry_sim_nereo), "kb_predictions")
})
