surveys <- function(...) {
  data.frame(
    site = fitted_sites(cover_biomass_nereo_fit, 3),
    year = "2019",
    canopy_area_m2 = c(200, 400, 800),
    tide_height_m = 0.5,
    region = c("north", "north", "south"),
    ...
  )
}

test_that("kb_predict_site_biomass gives one total per survey", {
  p <- kb_predict_site_biomass(cover_biomass_nereo_fit, surveys())
  expect_s3_class(p, "kb_predictions")
  expect_named(
    p,
    c(
      "site",
      "year",
      "canopy_area_m2",
      "tide_height_m",
      "region",
      "cover_support",
      "estimate",
      "lower",
      "upper"
    )
  )
  expect_identical(p$cover_support, rep("site, year", 3))
  expect_identical(attr(p, "kb_response"), "biomass_kg")
  expect_identical(attr(p, "kb_conf_level"), 0.95)
})

test_that("dry and carbon are per-draw conversions of wet", {
  args <- list(
    cover_biomass_nereo_fit,
    surveys(),
    wetdry_nereo_fit,
    carbon_nereo_fit,
    sig_fig = 10
  )
  withr::local_seed(1)
  wet <- do.call(kb_predict_site_biomass, args)
  dry <- do.call(kb_predict_site_biomass, c(args, measure = "dry"))
  carbon <- do.call(kb_predict_site_biomass, c(args, measure = "carbon"))
  # every row is a fitted site and year, so the draws are the same each call
  ratio <- population_draws(wetdry_nereo_fit)
  fraction <- population_draws(carbon_nereo_fit)
  totals <- site_biomass_draws(
    cover_biomass_nereo_fit,
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
  fit <- cover_biomass_nereo_fit
  p <- kb_predict_site_biomass(fit, surveys(), sum_by = "region", sig_fig = 10)
  expect_named(p, c("region", "estimate", "lower", "upper"))
  expect_identical(attr(p, "kb_group_vars"), "region")
  totals <- site_biomass_draws(fit, surveys(), "sample", NULL)
  expect_equal(
    p$estimate[1],
    stats::median(totals[, 1] + totals[, 2]),
    ignore_attr = TRUE
  )
  rows <- kb_predict_site_biomass(fit, surveys(), sig_fig = 10)
  expect_false(isTRUE(all.equal(p$lower[1], sum(rows$lower[1:2]))))
})

test_that("an unseen site is sampled by default, wider than averaged", {
  nd <- transform(surveys()[1, ], site = "new_site")
  withr::local_seed(1)
  sampled <- kb_predict_site_biomass(cover_biomass_nereo_fit, nd)
  averaged <- kb_predict_site_biomass(
    cover_biomass_nereo_fit,
    nd,
    new_levels = "average"
  )
  expect_identical(sampled$cover_support, "year")
  expect_gte(sampled$upper - sampled$lower, averaged$upper - averaged$lower)
})

test_that("results are reproducible under a seed", {
  nd <- transform(
    surveys(),
    site = c("new1", "new2", fitted_sites(cover_biomass_nereo_fit))
  )
  withr::local_seed(3)
  a <- kb_predict_site_biomass(cover_biomass_macro_fit, nd)
  withr::local_seed(3)
  b <- kb_predict_site_biomass(cover_biomass_macro_fit, nd)
  expect_identical(a, b)
})

test_that("missing, invalid, and mismatched inputs error", {
  fit <- cover_biomass_nereo_fit
  expect_snapshot(kb_predict_site_biomass(fit), error = TRUE)
  expect_snapshot(
    kb_predict_site_biomass(fit, surveys(), measure = "carbon", wetdry = wetdry_nereo_fit),
    error = TRUE
  )
  expect_snapshot(
    kb_predict_site_biomass(fit, surveys(site_area_m2 = 300)),
    error = TRUE
  )
  expect_snapshot(
    kb_predict_site_biomass(fit, surveys(), sum_by = "zone"),
    error = TRUE
  )
  expect_error(
    kb_predict_site_biomass(fit, surveys(), wetdry_macro_fit, measure = "dry"),
    "one species"
  )
  expect_error(kb_predict_site_biomass(weight_fit, surveys()), "kb_fit_cover_biomass")
  expect_error(
    kb_predict_site_biomass(fit, surveys()[c("site", "year", "canopy_area_m2")]),
    "tide_height_m"
  )
})
