test_that("posterior_epred returns a D x N matrix of positive expected weights", {
  m <- posterior_epred(weight_fit, newdata = data.frame(diameter = c(20, 40, 60)))
  expect_true(is.matrix(m))
  expect_equal(ncol(m), 3L)
  expect_equal(nrow(m), posterior::ndraws(weight_fit$draws))
  expect_true(all(m > 0))
})

test_that("posterior_epred at observed data has one column per observed row", {
  m <- posterior_epred(weight_fit)
  expect_equal(ncol(m), nrow(weight_fit$data))
})
