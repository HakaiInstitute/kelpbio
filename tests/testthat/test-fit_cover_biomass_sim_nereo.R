test_that("fit_cover_biomass_sim_nereo is a kb_fit_cover_biomass the accessors operate on", {
  expect_s3_class(fit_cover_biomass_sim_nereo, "kb_fit_cover_biomass_nereo")
  expect_s3_class(fit_cover_biomass_sim_nereo, "kb_fit_cover_biomass")
  expect_identical(fit_cover_biomass_sim_nereo$meta$species, "nereocystis")
  expect_true(nobs(fit_cover_biomass_sim_nereo) > 0L)
  expect_s3_class(tidy(fit_cover_biomass_sim_nereo), "tbl_df")
  expect_s3_class(
    kb_predict_cover_biomass(
      fit_cover_biomass_sim_nereo,
      kb_new_data(fit_cover_biomass_sim_nereo, by = "site")
    ),
    "kb_predictions"
  )
})
