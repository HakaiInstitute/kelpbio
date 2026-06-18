test_that("kb_prior_normal constructs a family-tagged object", {
  p <- kb_prior_normal(mean = 0, sd = 2)
  expect_s3_class(p, "kb_prior_normal")
  expect_s3_class(p, "kb_prior")
  expect_equal(p$mean, 0)
  expect_equal(p$sd, 2)
})

test_that("kb_prior_normal validates hyperparameters", {
  expect_error(kb_prior_normal(0, sd = -1))
  expect_error(kb_prior_normal(0, sd = 0))
  expect_error(kb_prior_normal(mean = "a", sd = 1))
})
