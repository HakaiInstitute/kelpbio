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
  expect_true(all(c("rhat", "ess_bulk", "ess_tail") %in% names(summary)))
})

test_that("as_draws is re-exported, so it needs no posterior::", {
  expect_identical(kelpbio::as_draws, posterior::as_draws)
})

test_that("posterior's draw counts read a fit's draws", {
  draws <- kb_samples(weight_nereo_fit)
  expect_identical(nchains(weight_nereo_fit), posterior::nchains(draws))
  expect_identical(niterations(weight_nereo_fit), posterior::niterations(draws))
  expect_identical(ndraws(weight_nereo_fit), posterior::ndraws(draws))
  expect_identical(nvariables(weight_nereo_fit), posterior::nvariables(draws))
  expect_identical(variables(weight_nereo_fit), posterior::variables(draws))
})
