test_that("kb_prior_exponential constructs a family-tagged object", {
  p <- kb_prior_exponential(rate = 1)
  expect_s3_class(p, "kb_prior_exponential")
  expect_s3_class(p, "kb_prior")
  expect_equal(p$rate, 1)
})

test_that("kb_prior_exponential validates the rate", {
  expect_error(kb_prior_exponential(rate = 0))
  expect_error(kb_prior_exponential(rate = -1))
})
