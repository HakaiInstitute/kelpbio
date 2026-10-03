test_that("fit_carbon_sim_nereo is a kb_fit_carbon the accessors operate on", {
  expect_s3_class(fit_carbon_sim_nereo, "kb_fit_carbon_nereo")
  expect_s3_class(fit_carbon_sim_nereo, "kb_fit_carbon")
  expect_identical(fit_carbon_sim_nereo$meta$species, "nereocystis")
  expect_true(nobs(fit_carbon_sim_nereo) > 0L)
  expect_s3_class(tidy(fit_carbon_sim_nereo), "tbl_df")
  expect_s3_class(kb_predict_carbon(fit_carbon_sim_nereo), "kb_predictions")
})
