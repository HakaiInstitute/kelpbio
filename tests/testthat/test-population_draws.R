test_that("population draws are the expected ratio per draw", {
  expect_equal(
    population_draws(carbon_nereo_fit),
    stats::plogis(as.vector(posterior::draws_of(carbon_nereo_fit$draws$bCarbon)))
  )
  expect_length(population_draws(wetdry_macro_fit), posterior::ndraws(wetdry_macro_fit$draws))
})
