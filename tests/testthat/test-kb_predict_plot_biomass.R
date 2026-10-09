test_that("one row per density-surveyed site-year, with flags and metadata", {
  withr::local_seed(1)
  p <- kb_predict_plot_biomass(weight_nereo_fit, size_nereo_fit, density_nereo_fit)
  expect_s3_class(p, "kb_predictions")
  expect_named(
    p,
    c("site", "year", "weight_support", "size_support", "estimate", "lower", "upper")
  )
  keys <- unique(site_year_key(density_nereo_fit$data$site, density_nereo_fit$data$year))
  expect_setequal(site_year_key(p$site, p$year), keys)
  expect_true(all(p$lower <= p$estimate & p$estimate <= p$upper))
  expect_identical(attr(p, "kb_response"), "biomass_kg_m2")
  expect_identical(attr(p, "kb_conf_level"), 0.95)
})

test_that("a site-year the weight fit did not observe is reported and still predicted", {
  withr::local_seed(1)
  p <- kb_predict_plot_biomass(weight_macro_fit, size_macro_fit, density_macro_fit)
  missing <- !site_year_key(p$site, p$year) %in% weight_macro_fit$meta$site_year_levels
  expect_true(any(missing))
  expect_true(all(p$weight_support[!missing] == "site-year"))
  expect_true(all(p$weight_support[missing] != "site-year"))
  expect_true(all(is.finite(p$estimate)))
})

test_that("sampling an unseen year is at least as wide as averaging it", {
  withr::local_seed(1)
  sampled <- kb_predict_plot_biomass(weight_macro_fit, size_macro_fit, density_macro_fit)
  averaged <- kb_predict_plot_biomass(
    weight_macro_fit,
    size_macro_fit,
    density_macro_fit,
    new_levels = "average"
  )
  # A "site, year" row adds only the small site:year effect, within Monte Carlo
  # error on the fixture's draws.
  unseen <- sampled$weight_support %in% c("site", "year", "none")
  expect_true(any(unseen))
  expect_true(all(
    (sampled$upper - sampled$lower)[unseen] >= (averaged$upper - averaged$lower)[unseen]
  ))
})

test_that("results are reproducible under a seed", {
  withr::local_seed(3)
  a <- kb_predict_plot_biomass(weight_macro_fit, size_macro_fit, density_macro_fit)
  withr::local_seed(3)
  b <- kb_predict_plot_biomass(weight_macro_fit, size_macro_fit, density_macro_fit)
  expect_identical(a, b)
})

test_that("dry and carbon are per-draw conversions of wet biomass", {
  local_mocked_bindings(population_draws = function(fit) {
    rep(if (inherits(fit, "kb_fit_wetdry")) 0.1 else 0.3, 600)
  })
  args <- list(weight_nereo_fit, size_nereo_fit, density_nereo_fit, wetdry_nereo_fit, carbon_nereo_fit)
  wet <- do.call(kb_predict_plot_biomass, c(args, new_levels = "average", sig_fig = 10))
  dry <- do.call(kb_predict_plot_biomass, c(args, measure = "dry", new_levels = "average", sig_fig = 10))
  carbon <- do.call(kb_predict_plot_biomass, c(args, measure = "carbon", new_levels = "average", sig_fig = 10))
  expect_equal(dry$estimate, wet$estimate * 0.1)
  expect_equal(carbon$estimate, wet$estimate * 0.1 * 0.3 * 1000)
  expect_identical(attr(dry, "kb_response"), "dry_biomass_kg_m2")
  expect_identical(attr(carbon, "kb_response"), "carbon_biomass_g_m2")
})

test_that("a missing conversion fit errors naming it", {
  expect_snapshot(
    kb_predict_plot_biomass(weight_nereo_fit, size_nereo_fit, density_nereo_fit, measure = "dry"),
    error = TRUE
  )
  expect_error(
    kb_predict_plot_biomass(
      weight_nereo_fit,
      size_nereo_fit,
      density_nereo_fit,
      wetdry_nereo_fit,
      measure = "carbon"
    ),
    "carbon"
  )
})

test_that("mismatched or wrong fits error", {
  expect_snapshot(
    kb_predict_plot_biomass(weight_nereo_fit, size_macro_fit, density_nereo_fit),
    error = TRUE
  )
  expect_snapshot(
    kb_predict_plot_biomass(fit_weight_sim_nereo, size_nereo_fit, density_nereo_fit),
    error = TRUE
  )
  expect_error(
    kb_predict_plot_biomass(density_nereo_fit, size_nereo_fit, density_nereo_fit),
    "kb_fit_weight"
  )
  expect_error(
    kb_predict_plot_biomass(weight_nereo_fit, size_nereo_fit, density_nereo_fit, wetdry = carbon_nereo_fit, measure = "dry"),
    "kb_fit_wetdry"
  )
})

test_that("arguments are validated", {
  expect_error(
    kb_predict_plot_biomass(weight_nereo_fit, size_nereo_fit, density_nereo_fit, representative_site = "nowhere"),
    "representative_site"
  )
  expect_error(
    kb_predict_plot_biomass(weight_nereo_fit, size_nereo_fit, density_nereo_fit, n_plants = 0)
  )
  expect_error(
    kb_predict_plot_biomass(weight_nereo_fit, size_nereo_fit, density_nereo_fit, measure = "blade")
  )
  expect_error(kb_predict_plot_biomass(weight_nereo_fit, size_nereo_fit, density_nereo_fit, 1, 2, 3))
})

test_that("nereo plant sizes are increasing quantiles below the upper bound", {
  nd <- posterior::ndraws(size_nereo_fit$draws)
  lp <- rep(log(30), nd)
  u <- (seq_len(50) - 0.5) / 50
  sizes <- .plant_sizes(size_nereo_fit, lp, upper = 60, u)
  expect_equal(dim(sizes), c(nd, 50L))
  expect_true(all(sizes > 0 & sizes <= 60))
  expect_true(all(apply(sizes, 1, diff) > 0))
})

test_that("nereo plant sizes average to the truncated Weibull mean", {
  lp <- log(30)
  shape <- posterior::draws_of(size_nereo_fit$draws$shape)[1]
  fit <- size_nereo_fit
  fit$draws$shape <- posterior::rvar(shape)
  scale <- weibull_scale(30, shape)
  upper <- 50
  u <- (seq_len(2000) - 0.5) / 2000
  truncated_mean <- stats::integrate(
    function(x) x * stats::dweibull(x, shape, scale),
    0,
    upper
  )$value / stats::pweibull(upper, shape, scale)
  expect_equal(mean(.plant_sizes(fit, lp, upper, u)), truncated_mean, tolerance = 1e-3)
})

test_that("macro plant sizes are whole frond counts from 1 to the upper bound", {
  nd <- posterior::ndraws(size_macro_fit$draws)
  lp <- rep(log(8), nd)
  u <- (seq_len(100) - 0.5) / 100
  fronds <- .plant_sizes(size_macro_fit, lp, upper = 20, u)
  expect_equal(dim(fronds), c(nd, 100L))
  expect_true(all(fronds >= 1 & fronds <= 20 & fronds == round(fronds)))
})

test_that("the size generic errors for a fit without a method", {
  expect_error(.plant_sizes(weight_nereo_fit, 0, 1, 0.5))
})

test_that("progress_dir records a complete prediction for kb_progress", {
  d <- withr::local_tempdir()
  withr::local_seed(1)
  kb_predict_plot_biomass(
    weight_nereo_fit,
    size_nereo_fit,
    density_nereo_fit,
    progress = "none",
    progress_dir = d
  )
  expect_identical(kb_progress(d), 1)
})

test_that("progress arguments are validated", {
  expect_error(
    kb_predict_plot_biomass(weight_nereo_fit, size_nereo_fit, density_nereo_fit, progress = "verbose")
  )
  expect_error(
    kb_predict_plot_biomass(weight_nereo_fit, size_nereo_fit, density_nereo_fit, progress_dir = "no/such/dir"),
    "progress_dir"
  )
})

test_that("a density or size fit with no observations errors naming it", {
  density0 <- density_nereo_fit
  density0$data <- density0$data[0, ]
  expect_error(
    kb_predict_plot_biomass(weight_nereo_fit, size_nereo_fit, density0),
    "`density` must be fitted"
  )
  size0 <- size_nereo_fit
  size0$data <- size0$data[0, ]
  expect_error(
    kb_predict_plot_biomass(weight_nereo_fit, size0, density_nereo_fit),
    "`size` must be fitted"
  )
})
