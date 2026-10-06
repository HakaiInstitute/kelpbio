test_that("fit_size_sim_macro is a kb_fit_size the accessors operate on", {
  expect_s3_class(fit_size_sim_macro, "kb_fit_size_macro")
  expect_s3_class(fit_size_sim_macro, "kb_fit_size")
  expect_identical(fit_size_sim_macro$meta$species, "macrocystis")
  expect_true(nobs(fit_size_sim_macro) > 0L)
  expect_s3_class(tidy(fit_size_sim_macro), "tbl_df")
  expect_s3_class(
    kb_predict_size(fit_size_sim_macro, kb_new_data(fit_size_sim_macro, by = "site")),
    "kb_predictions"
  )
})
