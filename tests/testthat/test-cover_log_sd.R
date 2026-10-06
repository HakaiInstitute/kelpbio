test_that("cover_log_sd recovers the log SD of symmetric lognormal limits", {
  sd_log <- c(0.2, 0.5)
  est <- c(1, 4)
  z <- stats::qnorm(0.975)
  lower <- est * exp(-z * sd_log)
  upper <- est * exp(z * sd_log)
  expect_equal(cover_log_sd(lower, upper, 0.95), sd_log)
})

test_that("cover_log_sd uses the interval level", {
  z <- stats::qnorm(0.95)
  expect_equal(cover_log_sd(exp(-z), exp(z), 0.9), 1)
})
