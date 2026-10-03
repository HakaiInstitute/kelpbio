test_that("kb_predict_carbon returns one row equal to every fitted value", {
  for (fit in list(carbon_nereo_fit, carbon_macro_fit)) {
    p <- kb_predict_carbon(fit)
    expect_s3_class(p, "kb_predictions")
    expect_equal(nrow(p), 1L)
    expect_named(p, c("estimate", "lower", "upper"))
    expect_identical(attr(p, "kb_response"), "carbon_fraction")
    expect_true(all(signif(augment(fit)$fitted, 3) == p$estimate))
    expect_gt(p$lower, 0)
    expect_lt(p$upper, 1)
  }
})

test_that("kb_predict_carbon honours the summary arguments and takes no new_data", {
  p <- kb_predict_carbon(carbon_nereo_fit, conf_level = 0.5, sig_fig = 5)
  wide <- kb_predict_carbon(carbon_nereo_fit)
  expect_lt(p$upper - p$lower, wide$upper - wide$lower)
  expect_error(
    kb_predict_carbon(carbon_nereo_fit, data.frame(x = 1)),
    class = "rlib_error_dots_nonempty"
  )
})

test_that("kb_predict_carbon errors on other models, and the result has no plot", {
  expect_error(kb_predict_carbon(weight_fit), "must be a <kb_fit_carbon> object")
  expect_error(kb_predict_carbon(1), "must be a <kb_fit_carbon> object")
  expect_error(kb_predict_size(carbon_nereo_fit), "must be a <kb_fit_size>")
  expect_error(
    kb_plot_predictions(kb_predict_carbon(carbon_nereo_fit)),
    "Cannot infer the x-axis"
  )
})

test_that("predict() wraps kb_predict_carbon()", {
  expect_equal(predict(carbon_macro_fit), kb_predict_carbon(carbon_macro_fit))
})
