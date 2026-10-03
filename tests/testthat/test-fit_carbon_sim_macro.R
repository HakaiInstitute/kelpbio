test_that("fit_carbon_sim_macro is a kb_fit_carbon the accessors operate on", {
  expect_s3_class(fit_carbon_sim_macro, "kb_fit_carbon_macro")
  expect_s3_class(fit_carbon_sim_macro, "kb_fit_carbon")
  expect_identical(fit_carbon_sim_macro$meta$species, "macrocystis")
  expect_true(nobs(fit_carbon_sim_macro) > 0L)
  expect_s3_class(tidy(fit_carbon_sim_macro), "tbl_df")
  expect_s3_class(kb_predict_carbon(fit_carbon_sim_macro), "kb_predictions")
})
