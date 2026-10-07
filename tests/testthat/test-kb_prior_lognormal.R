test_that("kb_prior_lognormal constructs a family-tagged object", {
  p <- kb_prior_lognormal(meanlog = 2, sdlog = 1)
  expect_s3_class(p, "kb_prior_lognormal")
  expect_s3_class(p, "kb_prior")
  expect_equal(p$meanlog, 2)
  expect_equal(p$sdlog, 1)
})

test_that("kb_prior_lognormal validates hyperparameters", {
  expect_error(kb_prior_lognormal(0, sdlog = -1), class = "chk_error")
  expect_error(kb_prior_lognormal(0, sdlog = 0), class = "chk_error")
  expect_error(kb_prior_lognormal(meanlog = "a", sdlog = 1), class = "chk_error")
})

test_that("kb_prior_lognormal prints its family and hyperparameters", {
  expect_snapshot(print(kb_prior_lognormal(meanlog = 2, sdlog = 1)))
})
