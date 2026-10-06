test_that("fit_cover_biomass_sim_macro is a kb_fit_cover_biomass the accessors operate on", {
  expect_s3_class(fit_cover_biomass_sim_macro, "kb_fit_cover_biomass_macro")
  expect_s3_class(fit_cover_biomass_sim_macro, "kb_fit_cover_biomass")
  expect_identical(fit_cover_biomass_sim_macro$meta$species, "macrocystis")
  expect_true(nobs(fit_cover_biomass_sim_macro) > 0L)
  expect_s3_class(tidy(fit_cover_biomass_sim_macro), "tbl_df")
  expect_s3_class(
    kb_predict_cover_biomass(
      fit_cover_biomass_sim_macro,
      kb_new_data(fit_cover_biomass_sim_macro, by = "site")
    ),
    "kb_predictions"
  )
})
