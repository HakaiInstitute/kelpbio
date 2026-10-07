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
