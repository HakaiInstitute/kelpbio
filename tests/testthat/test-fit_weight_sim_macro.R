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
