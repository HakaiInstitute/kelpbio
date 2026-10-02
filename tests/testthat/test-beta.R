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
