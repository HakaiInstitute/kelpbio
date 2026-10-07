test_that("kb_samples returns a draws_rvars object carrying the fit's variables", {
  s <- kb_samples(weight_nereo_fit)
  expect_true(posterior::is_draws_rvars(s))
  expect_setequal(
    posterior::variables(s),
    posterior::variables(weight_nereo_fit$draws)
  )
  expect_equal(posterior::ndraws(s), posterior::ndraws(weight_nereo_fit$draws))
})

test_that("kb_samples errors on an object that is not a fit", {
  expect_error(kb_samples(1), "must be a <kb_fit> object")
  expect_equal(rlang::catch_cnd(kb_samples(1))$call, quote(kb_samples(1)))
})

test_that("kb_samples excludes effects the fit omitted", {
  off <- omit_terms(weight_nereo_fit, "density_slope")
  expect_false("density_slope" %in% posterior::variables(kb_samples(off)))
})
