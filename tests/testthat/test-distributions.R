test_that("log_lik_hurdle_gamma() adds the Gamma density only where present", {
  out <- log_lik_hurdle_gamma(c(0, 2), logit_p = stats::qlogis(0.8), shape = 4, rate = 2)
  expect_equal(out[1], log(0.2))
  expect_equal(out[2], log(0.8) + stats::dgamma(2, 4, 2, log = TRUE))
})

test_that("an empty value stays finite where the presence probability rounds to 1", {
  expect_equal(log_lik_hurdle_gamma(0, logit_p = 45, shape = 4, rate = 2), -45)
  expect_equal(res_hurdle_gamma(0, logit_p = 45, shape = 4, rate = 2), -sqrt(90))
})

test_that("res_hurdle_gamma() is signed by the difference from the expected value", {
  r <- res_hurdle_gamma(c(0, 5), logit_p = stats::qlogis(0.8), shape = 4, rate = 2)
  expect_lt(r[1], 0)
  expect_gt(r[2], 0)
  expect_equal(r[1], -sqrt(-2 * log(0.2)))
})

test_that("ran_hurdle_gamma() draws zeros at the hurdle and positive values elsewhere", {
  set.seed(1)
  x <- ran_hurdle_gamma(2000, logit_p = stats::qlogis(0.7), shape = 4, rate = 2)
  expect_equal(mean(x == 0), 0.3, tolerance = 0.1)
  expect_true(all(x >= 0))
})
