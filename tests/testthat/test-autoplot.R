test_that("autoplot forwards to kb_plot_predictions and returns a ggplot", {
  # autoplot() is a pure pass-through; the plot behaviour lives in
  # test-kb_plot_predictions.R. This confirms delegation and arg forwarding.
  p <- kb_predict_weight_by(weight_fit, by = "site")
  gg <- ggplot2::autoplot(p, observed = weight_fit$data)
  expect_s3_class(gg, "ggplot")
  geoms <- vapply(gg$layers, function(l) class(l$geom)[1], character(1))
  expect_true(any(grepl("GeomPoint", geoms)))
})
