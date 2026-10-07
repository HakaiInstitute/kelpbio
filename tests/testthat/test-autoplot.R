test_that("autoplot forwards to kb_plot_predictions and returns a ggplot", {
  p <- kb_predict_weight(weight_nereo_fit, kb_new_data(weight_nereo_fit, by = "site"))
  gg <- ggplot2::autoplot(p, x = "site")
  expect_s3_class(gg, "ggplot")
  expect_identical(gg$labels$x, "Site")
})
