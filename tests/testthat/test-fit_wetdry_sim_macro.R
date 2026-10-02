test_that("fit_wetdry_sim_macro is a kb_fit_wetdry the accessors operate on", {
  expect_s3_class(fit_wetdry_sim_macro, "kb_fit_wetdry_macro")
  expect_s3_class(fit_wetdry_sim_macro, "kb_fit_wetdry")
  expect_identical(fit_wetdry_sim_macro$meta$species, "macrocystis")
  expect_true(nobs(fit_wetdry_sim_macro) > 0L)
  expect_s3_class(tidy(fit_wetdry_sim_macro), "tbl_df")
  expect_s3_class(kb_predict_wetdry(fit_wetdry_sim_macro), "kb_predictions")
})
