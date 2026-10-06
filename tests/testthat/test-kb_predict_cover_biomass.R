cover_rows <- function(...) {
  data.frame(canopy_area_m2 = 80, plot_area_m2 = 200, tide_height_m = 0.5, ...)
}

test_that("kb_predict_cover_biomass at the observed data matches augment", {
  for (fit in list(cover_biomass_nereo_fit, cover_biomass_macro_fit)) {
    p <- kb_predict_cover_biomass(fit)
    expect_s3_class(p, "kb_predictions")
    expect_equal(nrow(p), nobs(fit))
    expect_equal(p$estimate, signif(augment(fit)$fitted, 3))
    expect_identical(attr(p, "kb_response"), "biomass_kg_m2")
  }
})

test_that("predictions are returned at the supplied rows", {
  p <- kb_predict_cover_biomass(
    cover_biomass_nereo_fit,
    cover_rows(site = c("site1", "site2"), year = "2019"),
    new_levels = "average"
  )
  expect_named(
    p,
    c(
      "canopy_area_m2",
      "plot_area_m2",
      "tide_height_m",
      "site",
      "year",
      "estimate",
      "lower",
      "upper"
    )
  )
  expect_equal(nrow(p), 2L)
})

test_that("zero canopy predicts the floor for every site and year", {
  p <- kb_predict_cover_biomass(
    cover_biomass_macro_fit,
    data.frame(
      canopy_area_m2 = 0,
      plot_area_m2 = 200,
      tide_height_m = 0.5,
      site = c("site1", "site2", "site3"),
      year = c("2019", "2020", "2021")
    ),
    sig_fig = 8
  )
  expect_equal(p$estimate, rep(p$estimate[1], 3))
  floor <- stats::median(posterior::draws_of(cover_biomass_macro_fit$draws$bFloor))
  expect_equal(p$estimate[1], floor, tolerance = 1e-6)
})

test_that("biomass increases with canopy and with tide height", {
  p <- kb_predict_cover_biomass(
    cover_biomass_nereo_fit,
    data.frame(
      canopy_area_m2 = c(20, 80, 80),
      plot_area_m2 = 200,
      tide_height_m = c(0, 0, 1.5),
      site = "site1",
      year = "2019"
    ),
    sig_fig = 8
  )
  expect_true(p$estimate[2] > p$estimate[1])
  expect_true(p$estimate[3] > p$estimate[2])
})

test_that("new_data must carry valid survey columns", {
  expect_snapshot(
    kb_predict_cover_biomass(cover_biomass_nereo_fit, data.frame(canopy_area_m2 = 1, plot_area_m2 = 2)),
    error = TRUE
  )
  expect_error(
    kb_predict_cover_biomass(
      cover_biomass_nereo_fit,
      data.frame(canopy_area_m2 = 3, plot_area_m2 = 2, tide_height_m = 0)
    ),
    "canopy_area_m2"
  )
  expect_error(kb_predict_cover_biomass(cover_biomass_nereo_fit, 1), "must be a data frame")
})

test_that("a new site is sampled or averaged, and a representative site stands in", {
  withr::local_seed(1)
  nd <- cover_rows(site = "new_site")
  sampled <- kb_predict_cover_biomass(cover_biomass_nereo_fit, nd, new_levels = "sample")
  averaged <- kb_predict_cover_biomass(cover_biomass_nereo_fit, nd, new_levels = "average")
  expect_gte(sampled$upper - sampled$lower, averaged$upper - averaged$lower)

  rep <- kb_predict_cover_biomass(
    cover_biomass_nereo_fit,
    nd,
    new_levels = "average",
    representative_site = "site1"
  )
  known <- kb_predict_cover_biomass(
    cover_biomass_nereo_fit,
    cover_rows(site = "site1"),
    new_levels = "average"
  )
  expect_equal(rep$estimate, known$estimate)
})

test_that("a kb_new_data() grid gives curves over cover by group", {
  fit <- cover_biomass_nereo_fit
  p <- kb_predict_cover_biomass(fit, kb_new_data(fit, by = "site"))
  expect_equal(nrow(p), 30L * length(fit$meta$site_levels))
  expect_identical(attr(p, "kb_predictor"), "cover")
  expect_true(attr(p, "kb_curve"))
  expect_equal(range(p$cover), c(0, 1))

  pop <- kb_predict_cover_biomass(
    cover_biomass_macro_fit,
    kb_new_data(cover_biomass_macro_fit, cover = c(0, 0.5, 1))
  )
  expect_equal(nrow(pop), 3L)
  expect_true(all(diff(pop$estimate) > 0))
})

test_that("a cover grid agrees with unit-plot surveys at zero tide height", {
  fit <- cover_biomass_nereo_fit
  grid <- kb_predict_cover_biomass(
    fit,
    kb_new_data(fit, by = "site", cover = 0.5),
    sig_fig = 8
  )
  rows <- kb_predict_cover_biomass(
    fit,
    data.frame(
      site = grid$site,
      canopy_area_m2 = 50,
      plot_area_m2 = 100,
      tide_height_m = 0
    ),
    sig_fig = 8
  )
  expect_equal(grid$estimate, rows$estimate)
})

test_that("the default is the typical site, and a by argument is redirected", {
  nd <- cover_rows(site = "new_site")
  expect_identical(
    kb_predict_cover_biomass(cover_biomass_nereo_fit, nd),
    kb_predict_cover_biomass(cover_biomass_nereo_fit, nd, new_levels = "average")
  )
  expect_error(
    kb_predict_cover_biomass(cover_biomass_nereo_fit, by = "site"),
    "kb_new_data"
  )
})

test_that("kb_predict_cover_biomass errors on other models and a non-fit", {
  expect_error(kb_predict_cover_biomass(weight_fit), "must be a <kb_fit_cover_biomass> object")
  expect_snapshot(kb_predict_cover_biomass(1), error = TRUE)
})
