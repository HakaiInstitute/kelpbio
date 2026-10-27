test_that("res_beta matches a numerically maximised saturated likelihood", {
  alpha <- 0.088 * 170
  beta <- (1 - 0.088) * 170
  x <- c(0.05, 0.09, 0.2)
  ll_sat <- vapply(
    x,
    function(xx) {
      stats::optimise(
        function(m) stats::dbeta(xx, m * 170, (1 - m) * 170, log = TRUE),
        c(1e-6, 1 - 1e-6),
        maximum = TRUE,
        tol = 1e-12
      )$objective
    },
    numeric(1)
  )
  dev <- 2 * (ll_sat - stats::dbeta(x, alpha, beta, log = TRUE))
  expect_equal(res_beta(x, alpha, beta)^2, dev, tolerance = 1e-8)
})

test_that("res_beta is zero where the saturated mean equals the fitted mean", {
  alpha <- 15
  beta <- 155
  x0 <- stats::plogis(digamma(alpha) - digamma(beta))
  expect_equal(res_beta(x0, alpha, beta), 0, tolerance = 1e-8)
  expect_lt(res_beta(x0 - 0.01, alpha, beta), 0)
  expect_gt(res_beta(x0 + 0.01, alpha, beta), 0)
})

test_that("res_beta residuals are about standard normal under the model", {
  withr::local_seed(1)
  x <- stats::rbeta(2e4, 15, 155)
  r <- res_beta(x, 15, 155)
  expect_equal(mean(r), 0, tolerance = 0.1)
  expect_equal(stats::sd(r), 1, tolerance = 0.05)
})

test_that("ran_beta draws proportions with the Beta mean", {
  withr::local_seed(1)
  x <- ran_beta(2e4, 15, 155)
  expect_true(all(x > 0 & x < 1))
  expect_equal(mean(x), 15 / 170, tolerance = 0.02)
})

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
