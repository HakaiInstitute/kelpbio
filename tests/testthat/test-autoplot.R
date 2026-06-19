test_that("autoplot.kb_predictions returns a ggplot", {
  p <- kb_predict_weight(weight_fit, uncertainty = "typical")
  expect_s3_class(ggplot2::autoplot(p), "ggplot")
})

test_that("autoplot forwards arguments to kb_plot_predictions", {
  p <- kb_predict_weight(weight_fit, by = "site")
  gg <- ggplot2::autoplot(p, observed = weight_fit$data)
  geoms <- vapply(gg$layers, function(l) class(l$geom)[1], character(1))
  expect_true(any(grepl("GeomPoint", geoms)))
})
