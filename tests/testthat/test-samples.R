test_that("samples returns a posterior draws_rvars object", {
  expect_true(posterior::is_draws_rvars(samples(weight_fit)))
})
