test_that("predict_rows summarises the mean at each row", {
  grid <- kb_new_data(size_nereo_fit, by = "site")
  p <- predict_rows(
    size_nereo_fit,
    grid,
    new_levels = "average",
    representative_site = NULL,
    conf_level = 0.95,
    estimate = stats::median,
    sig_fig = 3
  )
  expect_s3_class(p, "kb_predictions")
  expect_identical(nrow(p), nrow(grid))
  expect_true(all(p$lower <= p$estimate & p$estimate <= p$upper))
})

test_that("errors from the shared checks name the prediction verb", {
  expect_snapshot(error = TRUE, {
    kb_predict_weight(weight_nereo_fit, data.frame(site = "a"))
    kb_predict_weight(weight_nereo_fit, conf_level = 2)
    kb_predict_size(size_nereo_fit, new_levels = "bogus")
    kb_predict_size(size_nereo_fit, representative_site = "bogus")
  })
})

test_that("a zero-observation fit names the function called", {
  fit0 <- size_nereo_fit
  fit0$data <- fit0$data[0, ]
  expect_snapshot(error = TRUE, {
    posterior_epred(fit0)
    residuals(fit0)
    log_lik(fit0)
  })
})
