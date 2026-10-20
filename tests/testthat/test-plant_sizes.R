test_that("plant_sizes gives quantiles of each draw's truncated Weibull", {
  fit <- size_nereo_fit
  lp <- rep(log(25), posterior::ndraws(fit$draws))
  u <- c(0.25, 0.5, 0.75)
  sizes <- plant_sizes(fit, lp, upper = 60, u = u)
  expect_equal(dim(sizes), c(length(lp), 3L))
  expect_true(all(sizes > 0 & sizes <= 60))
  expect_true(all(sizes[, 1] < sizes[, 2] & sizes[, 2] < sizes[, 3]))
  shape <- as.vector(posterior::draws_of(fit$draws$shape))
  scale <- weibull_scale(25, shape[1])
  p <- stats::pweibull(60, shape[1], scale) * u
  expect_equal(sizes[1, ], stats::qweibull(p, shape[1], scale))
})
