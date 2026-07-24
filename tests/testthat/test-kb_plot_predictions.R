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

test_that("axis titles are publication-ready descriptive labels", {
  p <- kb_predict_weight_by(weight_fit, new_levels = "average")
  gg <- kb_plot_predictions(p)
  expect_identical(gg$labels$x, "Sub-bulb diameter")
  expect_identical(gg$labels$y, "Wet weight")
})

test_that("a held predictor puts the grouping factor on a descriptive x axis", {
  p <- kb_predict_weight(
    weight_fit,
    new_data = data.frame(diameter = 30, site = levels(weight_fit$data$site)[1])
  )
  gg <- kb_plot_predictions(p)
  expect_identical(gg$labels$x, "Site")
  expect_identical(gg$labels$y, "Wet weight")
  geoms <- vapply(gg$layers, function(l) class(l$geom)[1], character(1))
  expect_true(any(grepl("GeomPointrange", geoms)))
})

test_that("reference-diameter by site is pointrange with sites on x, no facet", {
  p <- kb_predict_weight_by(
    weight_fit,
    by = "site",
    predictor = 30,
    new_levels = "average"
  )
  gg <- kb_plot_predictions(p)
  expect_identical(gg$labels$x, "Site")
  geoms <- vapply(gg$layers, function(l) class(l$geom)[1], character(1))
  expect_true(any(grepl("GeomPointrange", geoms)))
  expect_false(any(grepl("GeomRibbon", geoms)))
  expect_s3_class(gg$facet, "FacetNull")
})

test_that("reference-diameter by site:year puts year on x, facets by site", {
  p <- kb_predict_weight_by(weight_fit, by = c("site", "year"), predictor = 30)
  gg <- kb_plot_predictions(p)
  expect_identical(gg$labels$x, "Year")
  expect_false(inherits(gg$facet, "FacetNull"))
})

test_that("scattered supplied rows render as points, not a ribbon", {
  p <- kb_predict_weight(
    weight_fit,
    new_data = data.frame(diameter = c(20, 40, 60))
  )
  gg <- kb_plot_predictions(p)
  expect_identical(gg$labels$x, "Sub-bulb diameter")
  geoms <- vapply(gg$layers, function(l) class(l$geom)[1], character(1))
  expect_true(any(grepl("GeomPointrange", geoms)))
  expect_false(any(grepl("GeomRibbon", geoms)))
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

test_that("a single ungrouped row errors helpfully rather than cryptically", {
  p <- kb_predict_weight(weight_fit, new_data = data.frame(diameter = 30))
  expect_error(kb_plot_predictions(p), "Supply")
})

test_that("errors helpfully when metadata is stripped", {
  p <- kb_predict_weight_by(weight_fit, new_levels = "average")
  bare <- tibble::as_tibble(unclass(p))
  attr(bare, "kb_predictor") <- NULL
  expect_error(kb_plot_predictions(bare), "Cannot infer the x-axis")
})
