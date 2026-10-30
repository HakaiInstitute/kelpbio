test_that("mean_weight_draws gives one column of draws per site-year", {
  groups <- tibble::tibble(
    site = fitted_sites(size_nereo_fit, 2),
    year = size_nereo_fit$meta$year_levels[1]
  )
  draws <- mean_weight_draws(
    weight_nereo_fit, size_nereo_fit, groups,
    new_levels = "average", representative_site = NULL,
    n_plants = 20L, progress = "none", progress_dir = NULL
  )
  expect_equal(dim(draws), c(posterior::ndraws(size_nereo_fit$draws), 2L))
  expect_true(all(draws > 0))
})

test_that("mean_weight_draws shares a sampled new site across rows", {
  withr::local_seed(1)
  groups <- tibble::tibble(site = c("new", "new"), year = size_nereo_fit$meta$year_levels[1])
  draws <- mean_weight_draws(
    weight_nereo_fit, size_nereo_fit, groups,
    new_levels = "sample", representative_site = NULL,
    n_plants = 20L, progress = "none", progress_dir = NULL
  )
  expect_identical(draws[, 1], draws[, 2])
})

test_that("representative_sites gives a vector to every fit", {
  expect_identical(representative_sites("a"), list(weight = "a", size = "a"))
  expect_identical(representative_sites(NULL), list(weight = NULL, size = NULL))
})

test_that("representative_sites gives each fit its own list element", {
  expect_identical(
    representative_sites(list(weight = "a")),
    list(weight = "a", size = NULL)
  )
  expect_identical(
    representative_sites(list(size = "b", weight = "a")),
    list(weight = "a", size = "b")
  )
  expect_identical(representative_sites(list(weight = "a"), "weight"), list(weight = "a"))
})

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

test_that("mean plant weight averages the weight model's expected weight", {
  site <- fitted_sites(weight_nereo_fit)
  row <- tibble::tibble(site = site, year = "2019")
  nd <- posterior::ndraws(weight_nereo_fit$draws)
  sizes <- matrix(rep(c(20, 40), each = nd), nrow = nd)
  effects <- as.vector(posterior::draws_of(
    .group_effects(weight_nereo_fit, row, "average", NULL)
  ))
  got <- mean_plant_weight(weight_nereo_fit, sizes, effects)
  expected <- rowMeans(posterior_epred(
    weight_nereo_fit,
    data.frame(site = site, year = "2019", diameter_mm = c(20, 40)),
    new_levels = "average"
  ))
  expect_equal(got, expected)
})

test_that("the supplied effects are every plant's group effects", {
  row <- tibble::tibble(site = "new", year = weight_macro_fit$meta$year_levels[1])
  nd <- posterior::ndraws(weight_macro_fit$draws)
  sizes <- matrix(rep(c(3, 8), each = nd), nrow = nd)
  base <- mean_plant_weight(weight_macro_fit, sizes, rep(0, nd))
  # The Macrocystis mean is log-linear, so a shift in the effects scales it.
  shifted <- mean_plant_weight(weight_macro_fit, sizes, rep(0.5, nd))
  expect_equal(shifted, base * exp(0.5))
})
