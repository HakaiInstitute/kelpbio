test_that("log_lik returns a D x N matrix usable by loo", {
  ll <- log_lik(weight_fit)
  expect_true(is.matrix(ll))
  expect_equal(ncol(ll), nrow(weight_fit$data))
  expect_equal(nrow(ll), posterior::ndraws(weight_fit$draws))
  skip_if_not_installed("loo")
  expect_s3_class(suppressWarnings(loo::loo(ll)), "loo")
})
