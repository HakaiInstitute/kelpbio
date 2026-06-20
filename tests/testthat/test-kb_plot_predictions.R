test_that("kb_plot_predictions returns a ribbon ggplot for a continuous predictor", {
  p <- kb_predict_weight_by(weight_fit, new_levels = "average")
  gg <- kb_plot_predictions(p)
  expect_s3_class(gg, "ggplot")
  geoms <- vapply(gg$layers, function(l) class(l$geom)[1], character(1))
  expect_true(any(grepl("GeomRibbon", geoms)))
  expect_true(any(grepl("GeomLine", geoms)))
})

test_that("the weight-vs-diameter ribbon plot is visually stable", {
  skip_if_not_installed("vdiffr")
  p <- kb_predict_weight_by(weight_fit, new_levels = "average")
  vdiffr::expect_doppelganger("weight ribbon", kb_plot_predictions(p))
})

test_that("axis titles are publication-ready with units", {
  p <- kb_predict_weight_by(weight_fit, new_levels = "average")
  gg <- kb_plot_predictions(p)
  expect_identical(gg$labels$x, "Sub-bulb diameter (mm)")
  expect_identical(gg$labels$y, "Wet weight (kg)")
})

test_that("a categorical x axis gets a descriptive title without units", {
  p <- kb_predict_weight(
    weight_fit,
    new_data = data.frame(diameter_mm = 30, site = levels(weight_fit$data$site)[1])
  )
  gg <- kb_plot_predictions(p, x = "site", style = "pointrange")
  expect_identical(gg$labels$x, "Site")
  expect_identical(gg$labels$y, "Wet weight (kg)")
})

test_that("facet is inferred from grouping variables", {
  p <- kb_predict_weight_by(weight_fit, by = "site")
  gg <- kb_plot_predictions(p)
  expect_s3_class(gg, "ggplot")
  expect_false(inherits(gg$facet, "FacetNull"))
})

test_that("max_facets caps the panels with a warning", {
  p <- kb_predict_weight_by(weight_fit, by = c("site", "year"))
  expect_warning(kb_plot_predictions(p, max_facets = 4L), "first 4")
  expect_silent(kb_plot_predictions(p, max_facets = Inf))
})

test_that("observed overlay adds a points layer", {
  p <- kb_predict_weight_by(weight_fit, new_levels = "average")
  gg <- kb_plot_predictions(p, observed = weight_fit$data)
  geoms <- vapply(gg$layers, function(l) class(l$geom)[1], character(1))
  expect_true(any(grepl("GeomPoint", geoms)))
})

test_that("errors helpfully when metadata is stripped", {
  p <- kb_predict_weight_by(weight_fit, new_levels = "average")
  bare <- tibble::as_tibble(unclass(p))
  attr(bare, "kb_predictor") <- NULL
  expect_error(kb_plot_predictions(bare))
})
