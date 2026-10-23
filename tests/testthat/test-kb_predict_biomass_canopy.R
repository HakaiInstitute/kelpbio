surveys <- function(classified_area_m2 = 1e5, ...) {
  data.frame(
    site = fitted_sites(cover_calibration_nereo_fit, 3),
    year = "2019",
    canopy_area_m2 = c(200, 400, 800),
    canopy_tide_height_m = 0.5,
    classified_area_m2 = classified_area_m2,
    region = c("north", "north", "south"),
    ...
  )
}

test_that("kb_predict_biomass_canopy gives one total per survey", {
  p <- kb_predict_biomass_canopy(cover_calibration_nereo_fit, surveys())
  expect_s3_class(p, "kb_predictions")
  expect_named(
    p,
    c(
      "site",
      "year",
      "canopy_area_m2",
      "canopy_tide_height_m",
      "classified_area_m2",
      "region",
      "cover_support",
      "biomass_kg",
      "estimate",
      "lower",
      "upper"
    )
  )
  expect_identical(p$cover_support, rep("site, year", 3))
  expect_identical(attr(p, "kb_response"), "biomass_kg")
  expect_true(posterior::is_rvar(p$biomass_kg))
})

test_that("dry and carbon are per-draw conversions of wet", {
  args <- list(
    cover_calibration_nereo_fit,
    surveys(),
    wetdry_nereo_fit,
    carbon_nereo_fit,
    sig_fig = 10
  )
  withr::local_seed(1)
  wet <- do.call(kb_predict_biomass_canopy, args)
  dry <- do.call(kb_predict_biomass_canopy, c(args, measure = "dry"))
  carbon <- do.call(kb_predict_biomass_canopy, c(args, measure = "carbon"))
  # every row is a fitted site and year, so the draws are the same each call
  ratio <- population_draws(wetdry_nereo_fit)
  fraction <- population_draws(carbon_nereo_fit)
  totals <- canopy_biomass_draws(
    cover_calibration_nereo_fit,
    surveys(),
    "sample",
    NULL
  )
  expect_equal(dry$estimate, apply(totals * ratio, 2, stats::median))
  expect_equal(
    carbon$estimate,
    apply(totals * ratio * fraction, 2, stats::median)
  )
  expect_identical(attr(carbon, "kb_response"), "carbon_biomass_kg")
  expect_true(all(wet$estimate > dry$estimate))
})

test_that("sums are taken on the draws, not the summaries", {
  fit <- cover_calibration_nereo_fit
  p <- kb_predict_biomass_canopy(fit, surveys(), pool_by = "region", sig_fig = 10)
  expect_named(p, c("region", "biomass_kg", "estimate", "lower", "upper"))
  expect_identical(attr(p, "kb_group_vars"), "region")
  totals <- canopy_biomass_draws(fit, surveys(), "sample", NULL)
  expect_equal(
    p$estimate[1],
    stats::median(totals[, 1] + totals[, 2]),
    ignore_attr = TRUE
  )
  rows <- kb_predict_biomass_canopy(fit, surveys(), sig_fig = 10)
  expect_false(isTRUE(all.equal(p$lower[1], sum(rows$lower[1:2]))))
})

test_that("an unseen site is sampled by default, wider than averaged", {
  nd <- transform(surveys()[1, ], site = "new_site")
  withr::local_seed(1)
  sampled <- kb_predict_biomass_canopy(cover_calibration_nereo_fit, nd)
  averaged <- kb_predict_biomass_canopy(
    cover_calibration_nereo_fit,
    nd,
    new_levels = "average"
  )
  expect_identical(sampled$cover_support, "year")
  expect_gt(sampled$upper - sampled$lower, averaged$upper - averaged$lower)
})

test_that("results are reproducible under a seed", {
  nd <- transform(
    surveys(),
    site = c("new1", "new2", fitted_sites(cover_calibration_macro_fit))
  )
  withr::local_seed(3)
  a <- kb_predict_biomass_canopy(cover_calibration_macro_fit, nd)
  withr::local_seed(3)
  b <- kb_predict_biomass_canopy(cover_calibration_macro_fit, nd)
  expect_identical(a, b)
})

test_that("missing, invalid, and mismatched inputs error", {
  fit <- cover_calibration_nereo_fit
  expect_snapshot(kb_predict_biomass_canopy(fit), error = TRUE)
  expect_snapshot(
    kb_predict_biomass_canopy(fit, surveys(), measure = "carbon", wetdry = wetdry_nereo_fit),
    error = TRUE
  )
  expect_snapshot(
    kb_predict_biomass_canopy(fit, surveys(classified_area_m2 = 300)),
    error = TRUE
  )
  expect_snapshot(
    kb_predict_biomass_canopy(fit, surveys(), pool_by = "zone"),
    error = TRUE
  )
  expect_error(
    kb_predict_biomass_canopy(fit, surveys(), wetdry_macro_fit, measure = "dry"),
    "one species"
  )
  expect_error(kb_predict_biomass_canopy(weight_nereo_fit, surveys()), "kb_fit_cover_calibration")
  expect_error(kb_predict_biomass_canopy(fit, surveys()[0, ]), "at least one row")
})

test_that("pooling by site and year keeps cover_support", {
  p <- kb_predict_biomass_canopy(
    cover_calibration_nereo_fit,
    surveys(),
    pool_by = c("site", "year")
  )
  expect_identical(p$cover_support, rep("site, year", 3))
})

test_that("a repeated pool_by column pools as if named once", {
  fit <- cover_calibration_nereo_fit
  withr::local_seed(1)
  once <- kb_predict_biomass_canopy(fit, surveys(), pool_by = "region")
  withr::local_seed(1)
  twice <- kb_predict_biomass_canopy(fit, surveys(), pool_by = c("region", "region"))
  expect_identical(twice, once)
})

test_that("a pool_by group holding one site-year twice warns", {
  twice <- surveys()[c(1, 1), ]
  expect_warning(
    kb_predict_biomass_canopy(cover_calibration_nereo_fit, twice, pool_by = "region"),
    "overlap"
  )
})

test_that("high tides give finite, non-negative totals capped at the classified area", {
  fit <- cover_calibration_nereo_fit
  rows <- data.frame(
    site = fitted_sites(fit), year = "2019", canopy_area_m2 = 100,
    canopy_tide_height_m = c(0, 2, 3.5, 5), classified_area_m2 = 400
  )
  expect_warning(
    p <- kb_predict_biomass_canopy(fit, rows, new_levels = "average"),
    "past the tide limit"
  )
  draws <- posterior::draws_of(p$biomass_kg)
  expect_true(all(is.finite(draws) & draws >= 0))
  capped <- kb_predict_biomass_canopy(
    fit,
    transform(rows[1, ], canopy_area_m2 = 400),
    new_levels = "average"
  )
  expect_equal(draws[, 4], posterior::draws_of(capped$biomass_kg)[, 1], ignore_attr = TRUE)
})

test_that("a numeric year matches the fitted year and pools as character", {
  withr::local_seed(1)
  character_year <- kb_predict_biomass_canopy(
    cover_calibration_nereo_fit, surveys(),
    new_levels = "average", pool_by = "year"
  )
  withr::local_seed(1)
  numeric_year <- kb_predict_biomass_canopy(
    cover_calibration_nereo_fit, transform(surveys(), year = 2019),
    new_levels = "average", pool_by = "year"
  )
  expect_identical(numeric_year$year, "2019")
  expect_equal(numeric_year$biomass_kg, character_year$biomass_kg)
})

test_that("canopy biomass predictions match their snapshots", {
  expect_snapshot_data(
    kb_predict_biomass_canopy(cover_calibration_nereo_fit, surveys()),
    "nereo"
  )
  expect_snapshot_data(
    kb_predict_biomass_canopy(cover_calibration_nereo_fit, surveys(), pool_by = "region"),
    "nereo-region"
  )
})
