test_that("the censored Normal log density takes zero as the mass at or below zero", {
  expect_equal(
    log_lik_censored_normal(c(0, 2), mean = c(1, 1), sd = c(0.5, 0.5)),
    c(stats::pnorm(0, 1, 0.5, log.p = TRUE), stats::dnorm(2, 1, 0.5, log = TRUE))
  )
})

test_that("censored Normal deviance residuals are standardised, and negative at zero", {
  r <- res_censored_normal(c(0, 2), mean = c(1, 1), sd = c(0.5, 0.5))
  expect_equal(r[2], 2)
  expect_equal(r[1], -sqrt(-2 * stats::pnorm(0, 1, 0.5, log.p = TRUE)))
  expect_lt(r[1], 0)
})

test_that("censored Normal replicates are never negative", {
  withr::local_seed(1)
  x <- ran_censored_normal(1000, mean = 0.1, sd = 1)
  expect_true(all(x >= 0))
  expect_true(any(x == 0))
})
