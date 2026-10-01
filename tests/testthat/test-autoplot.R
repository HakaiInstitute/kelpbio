test_that("autoplot forwards to kb_plot_predictions and returns a ggplot", {
  # autoplot() is a pure pass-through; plot behaviour is tested in test-kb_plot_predictions.R
  p <- kb_predict_weight_by(weight_fit, by = "site")
  gg <- ggplot2::autoplot(p, x = "site")
  expect_s3_class(gg, "ggplot")
  expect_identical(gg$labels$x, "Site")
})
