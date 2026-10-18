test_that("nobs is the number of observations", {
  expect_equal(nobs(weight_nereo_fit), nrow(weight_nereo_fit$data))
  expect_equal(nobs(wetdry_nereo_fit), nrow(wetdry_nereo_fit$data))
})

test_that("draw counts and names exclude an effect the fit omitted", {
  off <- omit_terms(weight_nereo_fit, "weight_floor")
  expect_false("weight_floor" %in% variables(off))
  expect_equal(nvariables(off), nvariables(weight_nereo_fit) - 1L)
  expect_equal(glance(off)$K, glance(weight_nereo_fit)$K - 1L)
  expect_false("weight_floor" %in% posterior::summarise_draws(off)$variable)
})
