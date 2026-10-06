test_that("posterior_epred returns a D x N matrix of positive expected weights", {
  m <- posterior_epred(
    weight_fit,
    new_data = data.frame(diameter_mm = c(20, 40, 60))
  )
  expect_true(is.matrix(m))
  expect_equal(ncol(m), 3L)
  expect_equal(nrow(m), posterior::ndraws(weight_fit$draws))
  expect_true(all(m > 0))
})

test_that("new_data = NULL conditions on observed groups, agreeing with augment", {
  # observed data carries site/year, so each row is conditioned on its random
  # effects; one column per row, and the median matches augment's fitted
  m <- posterior_epred(weight_fit)
  expect_equal(ncol(m), nrow(weight_fit$data))
  med <- apply(m, 2, stats::median)
  expect_equal(med, augment(weight_fit)$fitted, tolerance = 1e-8)
})

test_that("macro posterior_epred agrees with posterior_linpred(transform = TRUE)", {
  # They coincide by model property, not construction: the Gamma mean is exp()
  # of the linear predictor.
  expect_equal(
    posterior_epred(weight_macro_fit, new_levels = "average"),
    posterior_linpred(weight_macro_fit, transform = TRUE, new_levels = "average")
  )
})

test_that("nereo posterior_epred is the lognormal mean, above the median", {
  # Normal on log weight: the mean is the median times exp(sWeight^2 / 2).
  ep <- posterior_epred(weight_fit, new_levels = "average")
  med <- posterior_linpred(weight_fit, transform = TRUE, new_levels = "average")
  sw <- as.vector(posterior::draws_of(weight_fit$draws$sWeight))
  expect_equal(ep, med * exp(sw^2 / 2))
  expect_true(all(ep > med))
})

test_that("rows naming one new site share its sampled effect", {
  withr::local_seed(1)
  y <- density_nereo_fit$meta$year_levels[1]
  p <- posterior_epred(
    density_nereo_fit,
    data.frame(site = c("new", "new", "other"), year = y, area_m2 = 10)
  )
  expect_identical(p[, 1], p[, 2])
  expect_false(identical(p[, 1], p[, 3]))
})
