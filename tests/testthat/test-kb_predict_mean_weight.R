test_that("kb_predict_mean_weight gives one row per sized site-year", {
  p <- kb_predict_mean_weight(weight_nereo_fit, size_nereo_fit, progress = "none")
  expect_s3_class(p, "kb_predictions")
  expect_equal(nrow(p), length(size_nereo_fit$meta$site_year_levels))
  expect_named(
    p,
    c("site", "year", "weight_support", "size_support", "weight_kg", "estimate", "lower", "upper")
  )
  expect_true(all(p$size_support == "site-year"))
  expect_true(posterior::is_rvar(p$weight_kg))
  expect_identical(attr(p, "kb_response"), "weight_kg")
})

test_that("a kb_new_data() grid gives the typical year at each site", {
  p <- kb_predict_mean_weight(
    weight_nereo_fit,
    size_nereo_fit,
    kb_new_data(size_nereo_fit, by = "site"),
    new_levels = "average",
    progress = "none"
  )
  expect_equal(nrow(p), length(size_nereo_fit$meta$site_levels))
  expect_identical(attr(p, "kb_group_vars"), "site")
})

test_that("dry and carbon weight are per-draw conversions of wet", {
  args <- list(weight_nereo_fit, size_nereo_fit, wetdry = wetdry_nereo_fit, carbon = carbon_nereo_fit)
  withr::local_seed(1)
  wet <- do.call(kb_predict_mean_weight, c(args, new_levels = "average", progress = "none"))
  withr::local_seed(1)
  carbon <- do.call(
    kb_predict_mean_weight,
    c(args, measure = "carbon", new_levels = "average", progress = "none")
  )
  factor <- population_draws(wetdry_nereo_fit) * population_draws(carbon_nereo_fit) * 1000
  expect_equal(
    posterior::draws_of(carbon$carbon_weight_g),
    posterior::draws_of(wet$weight_kg) * factor,
    ignore_attr = TRUE
  )
  expect_identical(attr(carbon, "kb_response"), "carbon_weight_g")
})

test_that("mismatched and missing inputs error", {
  expect_snapshot(
    kb_predict_mean_weight(weight_nereo_fit, size_nereo_fit, measure = "dry"),
    error = TRUE
  )
  expect_error(kb_predict_mean_weight(weight_macro_fit, size_nereo_fit), "one species")
  expect_error(kb_predict_mean_weight(size_nereo_fit, size_nereo_fit), "kb_fit_weight")
  expect_error(kb_predict_mean_weight(weight_nereo_fit, weight_nereo_fit), "kb_fit_size")
  expect_error(
    kb_predict_mean_weight(weight_nereo_fit, size_nereo_fit, n_plants = 0),
    "n_plants"
  )
})

test_that("progress can be polled", {
  dir <- withr::local_tempdir()
  kb_predict_mean_weight(weight_nereo_fit, size_nereo_fit, progress = "none", progress_dir = dir)
  expect_equal(kb_progress(dir), 1)
})

test_that("mean weight matches a direct integration over the size distribution", {
  row <- tibble::tibble(site = "otter_cove", year = "2020")
  p <- kb_predict_mean_weight(
    weight_nereo_fit, size_nereo_fit, row,
    new_levels = "average", n_plants = 1000, progress = "none"
  )
  draws <- 1:20
  upper <- max(size_nereo_fit$data$diameter_mm)
  x <- seq(upper / 4000, upper, length.out = 4000)
  lp <- posterior::draws_of(.linpred(size_nereo_fit, row, "average", NULL))[draws, 1]
  shape <- as.vector(posterior::draws_of(size_nereo_fit$draws$shape))[draws]
  scale <- weibull_scale(exp(lp), shape)
  # the grid spans sizes below the weighed range, which warns
  weight <- suppressWarnings(posterior_epred(
    weight_nereo_fit,
    data.frame(row, diameter_mm = x),
    new_levels = "average"
  ))[draws, ]
  expected <- vapply(seq_along(draws), function(d) {
    density <- stats::dweibull(x, shape[d], scale[d]) /
      stats::pweibull(upper, shape[d], scale[d])
    sum(diff(x) * (head(weight[d, ] * density, -1) + tail(weight[d, ] * density, -1)) / 2)
  }, numeric(1))
  got <- posterior::draws_of(p$weight_kg)[draws, 1]
  expect_equal(got, expected, tolerance = 0.01, ignore_attr = TRUE)
})

test_that("a size fit without observed data errors", {
  size <- size_nereo_fit
  size$data <- size$data[0, ]
  expect_snapshot(kb_predict_mean_weight(weight_nereo_fit, size), error = TRUE)
})

test_that("representative_site must be fitted in both fits", {
  size <- size_nereo_fit
  size$meta$site_levels <- setdiff(size$meta$site_levels, "heron_reef")
  expect_snapshot(
    kb_predict_mean_weight(weight_nereo_fit, size, representative_site = "heron_reef"),
    error = TRUE
  )
})
