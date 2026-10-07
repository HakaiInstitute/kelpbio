test_that("fit_carbon_sim_macro is a kb_fit_carbon the accessors operate on", {
  expect_s3_class(fit_carbon_sim_macro, "kb_fit_carbon_macro")
  expect_s3_class(fit_carbon_sim_macro, "kb_fit_carbon")
  expect_identical(fit_carbon_sim_macro$meta$species, "macrocystis")
  expect_true(nobs(fit_carbon_sim_macro) > 0L)
  expect_s3_class(tidy(fit_carbon_sim_macro), "tbl_df")
  expect_s3_class(kb_predict_carbon(fit_carbon_sim_macro), "kb_predictions")
})

test_that("fit_carbon_sim_nereo is a kb_fit_carbon the accessors operate on", {
  expect_s3_class(fit_carbon_sim_nereo, "kb_fit_carbon_nereo")
  expect_s3_class(fit_carbon_sim_nereo, "kb_fit_carbon")
  expect_identical(fit_carbon_sim_nereo$meta$species, "nereocystis")
  expect_true(nobs(fit_carbon_sim_nereo) > 0L)
  expect_s3_class(tidy(fit_carbon_sim_nereo), "tbl_df")
  expect_s3_class(kb_predict_carbon(fit_carbon_sim_nereo), "kb_predictions")
})

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

test_that("fit_density_sim_nereo is a kb_fit_density the accessors operate on", {
  expect_s3_class(fit_density_sim_nereo, "kb_fit_density_nereo")
  expect_s3_class(fit_density_sim_nereo, "kb_fit_density")
  expect_identical(fit_density_sim_nereo$meta$species, "nereocystis")
  expect_true(nobs(fit_density_sim_nereo) > 0L)
  expect_s3_class(tidy(fit_density_sim_nereo), "tbl_df")
  expect_s3_class(
    kb_predict_density(fit_density_sim_nereo, kb_new_data(fit_density_sim_nereo, by = "site")),
    "kb_predictions"
  )
})

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

test_that("fit_size_sim_nereo is a kb_fit_size the accessors operate on", {
  expect_s3_class(fit_size_sim_nereo, "kb_fit_size_nereo")
  expect_s3_class(fit_size_sim_nereo, "kb_fit_size")
  expect_identical(fit_size_sim_nereo$meta$species, "nereocystis")
  expect_true(nobs(fit_size_sim_nereo) > 0L)
  expect_s3_class(tidy(fit_size_sim_nereo), "tbl_df")
  expect_s3_class(
    kb_predict_size(fit_size_sim_nereo, kb_new_data(fit_size_sim_nereo, by = "site")),
    "kb_predictions"
  )
})

test_that("fit_weight_sim_macro is a kb_fit_weight the accessors operate on", {
  expect_s3_class(fit_weight_sim_macro, "kb_fit_weight_macro")
  expect_s3_class(fit_weight_sim_macro, "kb_fit_weight")
  expect_s3_class(fit_weight_sim_macro, "kb_fit")
  expect_identical(fit_weight_sim_macro$meta$species, "macrocystis")
  expect_true(nobs(fit_weight_sim_macro) > 0L)
  expect_s3_class(tidy(fit_weight_sim_macro), "tbl_df")
  expect_s3_class(
    kb_predict_weight(fit_weight_sim_macro, kb_new_data(fit_weight_sim_macro, by = "site")),
    "kb_predictions"
  )
})

test_that("fit_weight_sim_macro's group effects are labelled by level", {
  draws <- fit_weight_sim_macro$draws
  expect_identical(
    posterior::draws_of(draws$site_effect[["seal_ledge"]]),
    posterior::draws_of(draws$site_effect[[1]])
  )
  terms <- tidy(fit_weight_sim_macro, include_random_effects = TRUE)$term
  expect_true("site_effect[seal_ledge]" %in% terms)
  expect_true(any(startsWith(terms, "site_year_effect[seal_ledge,")))
})

test_that("fit_weight_sim_nereo is a kb_fit_weight the accessors operate on", {
  expect_s3_class(fit_weight_sim_nereo, "kb_fit_weight_nereo")
  expect_s3_class(fit_weight_sim_nereo, "kb_fit_weight")
  expect_s3_class(fit_weight_sim_nereo, "kb_fit")
  expect_true(nobs(fit_weight_sim_nereo) > 0L)
  expect_s3_class(tidy(fit_weight_sim_nereo), "tbl_df")
  expect_s3_class(
    kb_predict_weight(fit_weight_sim_nereo, kb_new_data(fit_weight_sim_nereo, by = "site")),
    "kb_predictions"
  )
})

test_that("fit_weight_sim_nereo's group effects are labelled by level", {
  draws <- fit_weight_sim_nereo$draws
  expect_identical(
    posterior::draws_of(draws$site_effect[["otter_cove"]]),
    posterior::draws_of(draws$site_effect[[1]])
  )
  terms <- tidy(fit_weight_sim_nereo, include_random_effects = TRUE)$term
  expect_true("site_effect[otter_cove]" %in% terms)
  expect_true(any(startsWith(terms, "site_year_effect[otter_cove,")))
})

test_that("fit_wetdry_sim_macro is a kb_fit_wetdry the accessors operate on", {
  expect_s3_class(fit_wetdry_sim_macro, "kb_fit_wetdry_macro")
  expect_s3_class(fit_wetdry_sim_macro, "kb_fit_wetdry")
  expect_identical(fit_wetdry_sim_macro$meta$species, "macrocystis")
  expect_true(nobs(fit_wetdry_sim_macro) > 0L)
  expect_s3_class(tidy(fit_wetdry_sim_macro), "tbl_df")
  expect_s3_class(kb_predict_wetdry(fit_wetdry_sim_macro), "kb_predictions")
})

test_that("fit_wetdry_sim_nereo is a kb_fit_wetdry the accessors operate on", {
  expect_s3_class(fit_wetdry_sim_nereo, "kb_fit_wetdry_nereo")
  expect_s3_class(fit_wetdry_sim_nereo, "kb_fit_wetdry")
  expect_identical(fit_wetdry_sim_nereo$meta$species, "nereocystis")
  expect_true(nobs(fit_wetdry_sim_nereo) > 0L)
  expect_s3_class(tidy(fit_wetdry_sim_nereo), "tbl_df")
  expect_s3_class(kb_predict_wetdry(fit_wetdry_sim_nereo), "kb_predictions")
})
