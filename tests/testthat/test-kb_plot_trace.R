trace_panels <- function(fit) {
  built <- ggplot2::ggplot_build(kb_plot_trace(fit))
  layer <- built$data[[1]]
  list(
    panels = nlevels(factor(layer$PANEL)),
    chains = length(unique(layer$group)),
    labels = as.character(built$layout$layout$term)
  )
}

test_that("kb_plot_trace draws one panel per tidy() term and one line per chain", {
  expect_s3_class(kb_plot_trace(weight_nereo_fit), "ggplot")
  trace <- trace_panels(weight_nereo_fit)
  expect_identical(trace$labels, tidy(weight_nereo_fit)$term)
  expect_identical(trace$chains, posterior::nchains(weight_nereo_fit$draws))
})

test_that("kb_plot_trace lays out ncol columns and labels the axes", {
  gg <- kb_plot_trace(weight_nereo_fit)
  expect_identical(gg$facet$params$ncol, 2L)
  expect_identical(gg$facet$params$free, list(x = FALSE, y = TRUE))
  expect_identical(kb_plot_trace(weight_nereo_fit, ncol = 3)$facet$params$ncol, 3)
  expect_identical(gg$labels$x, "Iteration")
  expect_identical(gg$labels$colour, "Chain")
})

test_that("kb_plot_trace sets no theme", {
  expect_length(kb_plot_trace(weight_nereo_fit)$theme, 0)
})

test_that("kb_plot_trace validates its arguments", {
  expect_snapshot(kb_plot_trace(1), error = TRUE)
  expect_error(kb_plot_trace(weight_nereo_fit, 1), "must be empty")
  expect_error(kb_plot_trace(weight_nereo_fit, ncol = 1.5), "ncol")
  expect_error(kb_plot_trace(weight_nereo_fit, ncol = 0), "ncol")
})
