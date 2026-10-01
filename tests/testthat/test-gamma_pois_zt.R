test_that("log_lik_gamma_pois_zt is a probability mass function on the positive counts", {
  p <- exp(log_lik_gamma_pois_zt(1:5000, lambda = 3, theta = 0.6))
  expect_equal(sum(p), 1)
})

test_that("log_lik_gamma_pois_zt renormalises the negative binomial", {
  x <- c(1, 4, 12)
  p0 <- stats::dnbinom(0, mu = 3, size = 1 / 0.6)
  expected <- stats::dnbinom(x, mu = 3, size = 1 / 0.6, log = TRUE) - log(1 - p0)
  expect_equal(log_lik_gamma_pois_zt(x, 3, 0.6), expected)
})

test_that("mean_gamma_pois_zt is the truncated mean", {
  x <- 1:5000
  p <- exp(log_lik_gamma_pois_zt(x, lambda = 3, theta = 0.6))
  expect_equal(mean_gamma_pois_zt(3, 0.6), sum(x * p))
  expect_gt(mean_gamma_pois_zt(0.5, 0.6), 1)
})

test_that("mean_gamma_pois_zt works on an rvar and a draws matrix", {
  m <- matrix(c(0.5, 2, 8, 20), nrow = 2)
  rv <- posterior::rvar(m)
  expect_equal(mean_gamma_pois_zt(m, 0.6), matrix(mean_gamma_pois_zt(c(m), 0.6), 2))
  expect_equal(
    posterior::draws_of(mean_gamma_pois_zt(rv, 0.6)),
    posterior::draws_of(rv) / (1 - (1 + posterior::draws_of(rv) * 0.6)^(-1 / 0.6))
  )
})

test_that("ran_gamma_pois_zt draws positive whole numbers with the truncated mean", {
  withr::local_seed(1)
  x <- ran_gamma_pois_zt(20000, lambda = 1.5, theta = 0.6)
  expect_true(all(x >= 1))
  expect_true(all(x == round(x)))
  expect_equal(mean(x), mean_gamma_pois_zt(1.5, 0.6), tolerance = 0.02)
})

test_that("log_lik_sat_gamma_pois_zt matches a numerical maximisation", {
  x <- c(1, 2, 3, 10, 200)
  theta <- 0.6
  num <- vapply(
    x,
    function(xi) {
      stats::optimize(
        function(l) log_lik_gamma_pois_zt(xi, l, theta),
        c(1e-10, xi),
        maximum = TRUE,
        tol = 1e-12
      )$objective
    },
    numeric(1)
  )
  expect_equal(log_lik_sat_gamma_pois_zt(x, theta), num, tolerance = 1e-8)
  expect_equal(log_lik_sat_gamma_pois_zt(1, theta), 0)
})

test_that("res_gamma_pois_zt is zero where the count equals the truncated mean", {
  theta <- 0.6
  lambda <- stats::uniroot(
    function(l) mean_gamma_pois_zt(l, theta) - 5,
    c(1e-6, 5),
    tol = 1e-12
  )$root
  expect_equal(res_gamma_pois_zt(5, lambda, theta), 0, tolerance = 1e-5)
  r <- res_gamma_pois_zt(5, seq(0.01, 20, by = 0.01), theta)
  expect_true(all(diff(r) < 0))
})

test_that("res_gamma_pois_zt gives the same result for scalar and vector theta", {
  x <- c(1, 3, 3, 7, 1)
  lambda <- c(0.5, 2, 4, 6, 3)
  expect_equal(
    res_gamma_pois_zt(x, lambda, 0.6),
    res_gamma_pois_zt(x, lambda, rep(0.6, 5))
  )
})
