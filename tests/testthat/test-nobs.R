test_that("nobs is the number of observations", {
  expect_equal(nobs(weight_nereo_fit), nrow(weight_nereo_fit$data))
  expect_equal(nobs(wetdry_nereo_fit), nrow(wetdry_nereo_fit$data))
})

test_that("draw counts and names exclude an effect the fit omitted", {
  off <- omit_terms(weight_nereo_fit, "density_slope")
  expect_false("density_slope" %in% variables(off))
  expect_equal(nvariables(off), nvariables(weight_nereo_fit) - 1L)
  expect_equal(glance(off)$K, nvariables(off))
  expect_false("density_slope" %in% posterior::summarise_draws(off)$variable)
})
