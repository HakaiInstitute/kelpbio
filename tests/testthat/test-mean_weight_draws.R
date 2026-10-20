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
