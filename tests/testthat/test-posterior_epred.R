test_that("posterior_epred returns a D x N matrix of positive expected weights", {
  m <- posterior_epred(
    weight_nereo_fit,
    new_data = data.frame(diameter_mm = c(20, 40, 60))
  )
  expect_true(is.matrix(m))
  expect_equal(ncol(m), 3L)
  expect_equal(nrow(m), posterior::ndraws(weight_nereo_fit$draws))
  expect_true(all(m > 0))
})

test_that("new_data = NULL conditions on observed groups, agreeing with augment", {
  m <- posterior_epred(weight_nereo_fit)
  expect_equal(ncol(m), nrow(weight_nereo_fit$data))
  med <- apply(m, 2, stats::median)
  expect_equal(med, augment(weight_nereo_fit)$fitted, tolerance = 1e-8)
})

test_that("rows naming one new site share its sampled effect", {
  withr::local_seed(1)
  y <- size_nereo_fit$meta$year_levels[1]
  p <- posterior_epred(
    size_nereo_fit,
    data.frame(site = c("new", "new", "other"), year = y),
    new_levels = "sample"
  )
  expect_identical(p[, 1], p[, 2])
  expect_false(identical(p[, 1], p[, 3]))
})

test_that("the default new_levels is average, so a new site needs no seed", {
  nd <- data.frame(diameter_mm = 40, site = "new_site")
  expect_identical(
    posterior_epred(weight_nereo_fit, nd),
    posterior_epred(weight_nereo_fit, nd, new_levels = "average")
  )
})

test_that("errors name posterior_epred()", {
  err <- expect_error(posterior_epred(weight_nereo_fit, data.frame(diameter_mm = -1)))
  expect_identical(err$call[[1]], quote(posterior_epred))
  err <- expect_error(posterior_epred(weight_nereo_fit, NULL, 1))
  expect_identical(err$call[[1]], quote(posterior_epred))
})
