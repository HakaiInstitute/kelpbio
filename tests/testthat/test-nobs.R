test_that("nobs is the number of observations", {
  expect_equal(nobs(weight_nereo_fit), nrow(weight_nereo_fit$data))
  expect_equal(nobs(wetdry_nereo_fit), nrow(wetdry_nereo_fit$data))
})
