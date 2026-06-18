test_that("kb_plot_predictions returns a ribbon ggplot for a continuous predictor", {
  p <- kb_predict_weight(weight_fit, uncertainty = "typical")
  gg <- kb_plot_predictions(p)
  expect_s3_class(gg, "ggplot")
  geoms <- vapply(gg$layers, function(l) class(l$geom)[1], character(1))
  expect_true(any(grepl("GeomRibbon", geoms)))
  expect_true(any(grepl("GeomLine", geoms)))
})

test_that("facet is inferred from grouping variables", {
  p <- kb_predict_weight(weight_fit, by = "site")
  gg <- kb_plot_predictions(p)
  expect_s3_class(gg, "ggplot")
  expect_false(inherits(gg$facet, "FacetNull"))
})

test_that("observed overlay adds a points layer", {
  p <- kb_predict_weight(weight_fit, uncertainty = "typical")
  gg <- kb_plot_predictions(p, observed = weight_fit$data)
  geoms <- vapply(gg$layers, function(l) class(l$geom)[1], character(1))
  expect_true(any(grepl("GeomPoint", geoms)))
})

test_that("errors helpfully when metadata is stripped", {
  p <- kb_predict_weight(weight_fit, uncertainty = "typical")
  bare <- tibble::as_tibble(unclass(p))
  attr(bare, "kb_predictor") <- NULL
  expect_error(kb_plot_predictions(bare))
})
