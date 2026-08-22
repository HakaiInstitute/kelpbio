test_that("samples returns a draws_rvars object carrying the fit's variables", {
  s <- samples(weight_fit)
  expect_true(posterior::is_draws_rvars(s))
  expect_setequal(
    posterior::variables(s),
    posterior::variables(weight_fit$draws)
  )
  expect_equal(posterior::ndraws(s), posterior::ndraws(weight_fit$draws))
})

test_that("samples errors on an object that is not a fit", {
  expect_error(samples(1), "must be a <kb_fit> object")
  expect_equal(rlang::catch_cnd(samples(1))$call, quote(samples(1)))
})
