test_that("fit_density_sim_nereo is a kb_fit_density the accessors operate on", {
  expect_s3_class(fit_density_sim_nereo, "kb_fit_density_nereo")
  expect_s3_class(fit_density_sim_nereo, "kb_fit_density")
  expect_identical(fit_density_sim_nereo$meta$species, "nereocystis")
  expect_true(nobs(fit_density_sim_nereo) > 0L)
  expect_s3_class(tidy(fit_density_sim_nereo), "tbl_df")
  expect_s3_class(
    kb_predict_density_by(fit_density_sim_nereo, by = "site"),
    "kb_predictions"
  )
})
