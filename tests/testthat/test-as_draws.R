test_that("as_draws returns the same draws as kb_samples", {
  expect_identical(posterior::as_draws(size_nereo_fit), kb_samples(size_nereo_fit))
  expect_s3_class(posterior::as_draws(size_nereo_fit), "draws_rvars")
})

test_that("posterior conversions and summaries accept a fit", {
  df <- posterior::as_draws_df(weight_nereo_fit)
  expect_s3_class(df, "draws_df")
  expect_identical(
    posterior::variables(df),
    posterior::variables(posterior::as_draws_df(kb_samples(weight_nereo_fit)))
  )
  expect_s3_class(posterior::as_draws_array(weight_nereo_fit), "draws_array")
  summary <- posterior::summarise_draws(weight_nereo_fit)
  expect_true("intercept" %in% summary$variable)
})

test_that("as_draws leaves out an effect the fit omitted", {
  fit <- omit_terms(weight_nereo_fit, site_year_off(FALSE))
  vars <- posterior::variables(posterior::as_draws(fit))
  expect_false(any(c("sd_site_year", "site_year_effect") %in% vars))
})
