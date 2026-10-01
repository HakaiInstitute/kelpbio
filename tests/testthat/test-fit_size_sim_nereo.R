test_that("fit_size_sim_nereo is a kb_fit_size the accessors operate on", {
  expect_s3_class(fit_size_sim_nereo, "kb_fit_size_nereo")
  expect_s3_class(fit_size_sim_nereo, "kb_fit_size")
  expect_identical(fit_size_sim_nereo$meta$species, "nereocystis")
  expect_true(nobs(fit_size_sim_nereo) > 0L)
  expect_s3_class(tidy(fit_size_sim_nereo), "tbl_df")
  expect_s3_class(
    kb_predict_size_by(fit_size_sim_nereo, by = "site"),
    "kb_predictions"
  )
})
