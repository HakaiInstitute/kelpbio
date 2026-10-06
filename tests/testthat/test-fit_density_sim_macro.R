test_that("fit_density_sim_macro is a kb_fit_density the accessors operate on", {
  expect_s3_class(fit_density_sim_macro, "kb_fit_density_macro")
  expect_s3_class(fit_density_sim_macro, "kb_fit_density")
  expect_identical(fit_density_sim_macro$meta$species, "macrocystis")
  expect_true(nobs(fit_density_sim_macro) > 0L)
  expect_s3_class(tidy(fit_density_sim_macro), "tbl_df")
  expect_s3_class(
    kb_predict_density(fit_density_sim_macro, kb_new_data(fit_density_sim_macro, by = "site")),
    "kb_predictions"
  )
})
