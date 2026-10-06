test_that("weibull_scale makes the Weibull mean equal mu", {
  shape <- c(0.8, 2.5, 6)
  scale <- weibull_scale(30, shape)
  expect_equal(scale * gamma(1 + 1 / shape), rep(30, 3))
})

test_that("log_lik_weibull matches dweibull", {
  x <- c(5, 20, 60)
  expect_equal(
    log_lik_weibull(x, shape = 2.5, scale = 40),
    stats::dweibull(x, shape = 2.5, scale = 40, log = TRUE)
  )
})

test_that("res_weibull is the deviance against a numerically saturated fit", {
  x <- c(5, 20, 35, 40, 45, 70)
  shape <- 2.5
  scale <- 40
  ll_sat <- vapply(
    x,
    function(xi) {
      stats::optimize(
        function(s) stats::dweibull(xi, shape, s, log = TRUE),
        c(1e-3, 1e3),
        maximum = TRUE
      )$objective
    },
    numeric(1)
  )
  dev <- 2 * (ll_sat - log_lik_weibull(x, shape, scale))
  expect_equal(res_weibull(x, shape, scale)^2, dev, tolerance = 1e-8)
})

test_that("res_weibull equals the Exp(1) deviance residual of (x / scale)^shape", {
  x <- c(3, 25, 90)
  e <- (x / 40)^2.5
  expected <- sign(e - 1) * sqrt(2 * (e - 1 - log(e)))
  expect_equal(res_weibull(x, 2.5, 40), expected)
})

test_that("res_weibull is zero at the scale and signed against it", {
  shape <- 2.5
  scale <- 40
  mean <- scale * gamma(1 + 1 / shape)
  expect_equal(res_weibull(scale, shape, scale), 0)
  # between the mean and the scale an observation is below the saturated point
  expect_lt(res_weibull((mean + scale) / 2, shape, scale), 0)
  r <- res_weibull(seq(1, 100, by = 0.1), shape, scale)
  expect_true(all(diff(r) > 0))
})

test_that("ran_weibull draws with the Weibull mean", {
  withr::local_seed(1)
  x <- ran_weibull(2e4, shape = 2.5, scale = weibull_scale(30, 2.5))
  expect_true(all(x > 0))
  expect_equal(mean(x), 30, tolerance = 0.02)
})
