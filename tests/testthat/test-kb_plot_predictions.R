weight_curve <- function() {
  kb_predict_weight(weight_nereo_fit, kb_new_data(weight_nereo_fit))
}

geoms_of <- function(gg) vapply(gg$layers, function(l) class(l$geom)[1], character(1))

test_that("a continuous predictor gives a ribbon with descriptive axis titles", {
  gg <- kb_plot_predictions(weight_curve())
  expect_s3_class(gg, "ggplot")
  geoms <- geoms_of(gg)
  expect_true(any(grepl("GeomRibbon", geoms)))
  expect_true(any(grepl("GeomLine", geoms)))
  expect_identical(gg$labels$x, "Sub-bulb diameter (mm)")
  expect_identical(gg$labels$y, "Wet weight (kg)")
})

test_that("the weight-vs-diameter ribbon plot is visually stable", {
  skip_if_not_installed("vdiffr")
  p <- weight_curve()
  vdiffr::expect_doppelganger("weight ribbon", kb_plot_predictions(p))
})

test_that("a held predictor puts the grouping factor on a descriptive x axis", {
  p <- kb_predict_weight(
    weight_nereo_fit,
    new_data = data.frame(diameter_mm = 30, site = levels(weight_nereo_fit$data$site)[1])
  )
  gg <- kb_plot_predictions(p)
  expect_identical(gg$labels$x, "Site")
  expect_identical(gg$labels$y, "Wet weight (kg)")
  geoms <- geoms_of(gg)
  expect_true(any(grepl("GeomPointrange", geoms)))
})

test_that("reference-diameter by site is pointrange with sites on x, no facet", {
  p <- kb_predict_weight(
    weight_nereo_fit,
    kb_new_data(weight_nereo_fit, by = "site", diameter_mm = 30)
  )
  gg <- kb_plot_predictions(p)
  expect_identical(gg$labels$x, "Site")
  geoms <- geoms_of(gg)
  expect_true(any(grepl("GeomPointrange", geoms)))
  expect_false(any(grepl("GeomRibbon", geoms)))
  expect_s3_class(gg$facet, "FacetNull")
})

test_that("reference-diameter by site:year puts year on x, facets by site", {
  p <- kb_predict_weight(
    weight_nereo_fit,
    kb_new_data(weight_nereo_fit, by = c("site", "year"), diameter_mm = 30)
  )
  gg <- kb_plot_predictions(p)
  expect_identical(gg$labels$x, "Year")
  expect_false(inherits(gg$facet, "FacetNull"))
})

test_that("rows not from kb_new_data() render as points, not a ribbon", {
  p <- kb_predict_weight(
    weight_nereo_fit,
    new_data = data.frame(diameter_mm = c(20, 40, 60))
  )
  gg <- kb_plot_predictions(p)
  expect_identical(gg$labels$x, "Sub-bulb diameter (mm)")
  geoms <- geoms_of(gg)
  expect_true(any(grepl("GeomPointrange", geoms)))
  expect_false(any(grepl("GeomRibbon", geoms)))
  # the observed plants vary in diameter too, but are not a curve
  observed <- kb_plot_predictions(kb_predict_weight(weight_nereo_fit), max_facets = Inf)
  geoms <- geoms_of(observed)
  expect_false(any(grepl("GeomRibbon", geoms)))
})

test_that("max_facets caps the panels with a warning", {
  p <- kb_predict_weight(
    weight_nereo_fit,
    kb_new_data(weight_nereo_fit, by = c("site", "year"))
  )
  expect_warning(kb_plot_predictions(p, max_facets = 4L), "first 4")
  expect_silent(kb_plot_predictions(p, max_facets = Inf))
})

test_that("raw data can be added as a layer", {
  p <- weight_curve()
  gg <- kb_plot_predictions(p) +
    ggplot2::geom_point(ggplot2::aes(diameter_mm, weight_kg), data = weight_nereo_fit$data)
  expect_no_error(ggplot2::ggplot_build(gg))
  geoms <- geoms_of(gg)
  expect_true("GeomPoint" %in% geoms)
})

test_that("a single ungrouped row errors helpfully rather than cryptically", {
  p <- kb_predict_weight(weight_nereo_fit, new_data = data.frame(diameter_mm = 30))
  expect_error(kb_plot_predictions(p), "Supply")
})

test_that("errors helpfully when metadata is stripped", {
  p <- weight_curve()
  bare <- tibble::as_tibble(unclass(p))
  attr(bare, "kb_predictor") <- NULL
  expect_error(kb_plot_predictions(bare), "Cannot infer the x-axis")
})

test_that("size by site plots point ranges with a descriptive y axis", {
  p <- kb_predict_size(size_nereo_fit, kb_new_data(size_nereo_fit, by = "site"))
  gg <- kb_plot_predictions(p)
  geoms <- geoms_of(gg)
  expect_true(any(grepl("GeomPointrange", geoms)))
  expect_identical(gg$labels$x, "Site")
  expect_identical(gg$labels$y, "Sub-bulb diameter (mm)")
  expect_equal(min(ggplot2::layer_scales(gg)$y$range$range), 0)
})

mean_weight_by_site <- function() {
  kb_predict_mean_weight(
    weight_nereo_fit,
    size_nereo_fit,
    kb_new_data(size_nereo_fit, by = "site"),
    new_levels = "average",
    progress = "none"
  )
}

test_that("mean weight by site plots point ranges titled as a weight", {
  gg <- kb_plot_predictions(mean_weight_by_site())
  geoms <- geoms_of(gg)
  expect_true(any(grepl("GeomPointrange", geoms)))
  expect_identical(gg$labels$x, "Site")
  expect_identical(gg$labels$y, "Wet weight (kg)")
})

test_that("survey biomass by site-year plots point ranges titled as a biomass", {
  withr::local_seed(1)
  p <- kb_predict_biomass_survey(
    weight_nereo_fit,
    size_nereo_fit,
    data_survey_sim_nereo,
    pool_by = c("site", "year"),
    progress = "none"
  )
  gg <- kb_plot_predictions(p, max_facets = Inf)
  expect_identical(gg$labels$x, "Year")
  expect_identical(gg$labels$y, "Wet biomass (kg/m\u00b2)")
})

test_that("the size-by-site plot is visually stable", {
  skip_if_not_installed("vdiffr")
  p <- kb_predict_size(size_nereo_fit, kb_new_data(size_nereo_fit, by = "site"))
  vdiffr::expect_doppelganger("size by site", kb_plot_predictions(p))
})

test_that("a cover curve plots a ribbon over tide-corrected cover", {
  fit <- cover_calibration_nereo_fit
  p <- kb_predict_cover_calibration(fit, kb_new_data(fit))
  gg <- kb_plot_predictions(p)
  expect_s3_class(gg, "ggplot")
  geoms <- geoms_of(gg)
  expect_true(any(grepl("GeomRibbon", geoms)))
  expect_identical(gg$labels$x, "Tide-corrected canopy cover")
  expect_identical(gg$labels$y, "Wet biomass (kg/m\u00b2)")
})

test_that("log_axis defaults to linear axes with the y-axis from zero", {
  p <- mean_weight_by_site()
  gg <- kb_plot_predictions(p)
  # Linear: the scale leaves values untransformed.
  expect_identical(gg$scales$get_scales("y")$transform(10), 10)
  expect_equal(min(ggplot2::layer_scales(gg)$y$range$range), 0)
})

test_that("log_axis = 'y' log-scales the y-axis without a zero floor", {
  p <- mean_weight_by_site()
  gg <- kb_plot_predictions(p, log_axis = "y")
  expect_identical(gg$scales$get_scales("y")$trans$name, "log-10")
  expect_null(gg$scales$get_scales("x"))
  expect_gt(min(ggplot2::layer_scales(gg)$y$range$range), -Inf)
  expect_no_warning(ggplot2::ggplot_build(gg))
  expect_identical(gg$labels$y, "Wet weight (kg, log scale)")
  expect_identical(gg$labels$x, "Site")
})

test_that("log_axis = 'xy' log-scales both axes of a curve", {
  p <- weight_curve()
  gg <- kb_plot_predictions(p, log_axis = "xy")
  expect_identical(gg$scales$get_scales("x")$trans$name, "log-10")
  expect_identical(gg$scales$get_scales("y")$trans$name, "log-10")
  expect_identical(gg$labels$x, "Sub-bulb diameter (mm, log scale)")
  expect_identical(gg$labels$y, "Wet weight (kg, log scale)")
})

test_that("a log axis without a unit is titled as log scale", {
  expect_identical(axis_label("fronds", log = TRUE), "Fronds (log scale)")
  expect_identical(axis_label("fronds"), "Fronds")
})

test_that("a supplied x that is not one column errors helpfully", {
  p <- weight_curve()
  expect_error(kb_plot_predictions(p, x = c("diameter_mm", "site")), "string")
  expect_error(kb_plot_predictions(p, x = "nope"), "must name a column")
})

test_that("the log-log weight curve is visually stable", {
  skip_if_not_installed("vdiffr")
  p <- weight_curve()
  vdiffr::expect_doppelganger(
    "weight ribbon log-log",
    kb_plot_predictions(p, log_axis = "xy")
  )
})

test_that("tick labels are plain numbers", {
  expect_identical(
    plain_labels(c(0.001, 0.1, 1, 10, 1e5)),
    c("0.001", "0.1", "1", "10", "100,000")
  )
})

test_that("linear axes label large values in full", {
  p <- weight_curve()
  p$estimate <- p$estimate * 1e5
  p$lower <- p$lower * 1e5
  p$upper <- p$upper * 1e5
  gg <- kb_plot_predictions(p)
  labels <- ggplot2::ggplot_build(gg)$layout$panel_params[[1]]$y$get_labels()
  labels <- labels[!is.na(labels)]
  expect_false(any(grepl("e[+-]", labels)))
  expect_true(any(grepl(",", labels)))
})

test_that("a log x-axis errors over zero cover and over groups", {
  fit <- cover_calibration_nereo_fit
  p <- kb_predict_cover_calibration(fit, kb_new_data(fit))
  expect_snapshot(kb_plot_predictions(p, log_axis = "xy"), error = TRUE)
  gg <- kb_plot_predictions(p, log_axis = "y")
  expect_identical(gg$scales$get_scales("y")$get_transformation()$name, "log-10")
  positive <- kb_predict_cover_calibration(
    fit,
    kb_new_data(fit, cover = 10^seq(-3, 0, length.out = 5))
  )
  gg <- kb_plot_predictions(positive, log_axis = "xy")
  expect_identical(gg$scales$get_scales("x")$get_transformation()$name, "log-10")
  expect_identical(gg$scales$get_scales("y")$get_transformation()$name, "log-10")
  by_site <- mean_weight_by_site()
  expect_snapshot(kb_plot_predictions(by_site, log_axis = "xy"), error = TRUE)
})

test_that("a log y-axis errors over non-positive values", {
  p <- weight_curve()
  p$lower[1] <- 0
  expect_snapshot(kb_plot_predictions(p, log_axis = "y"), error = TRUE)
  expect_error(kb_plot_predictions(p, log_axis = "nope"), "must be one of")
})
