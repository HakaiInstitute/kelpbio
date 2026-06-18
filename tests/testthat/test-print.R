test_that("prior print methods show family and hyperparameters", {
  expect_snapshot(print(kb_prior_normal(mean = 0, sd = 2)))
  expect_snapshot(print(kb_prior_exponential(rate = 1)))
})
