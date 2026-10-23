test_that("errors from the shared checks name the prediction verb", {
  expect_snapshot(error = TRUE, {
    kb_predict_weight(weight_nereo_fit, data.frame(site = "a"))
    kb_predict_weight(weight_nereo_fit, conf_level = 2)
    kb_predict_size(size_nereo_fit, new_levels = "bogus")
    kb_predict_size(size_nereo_fit, representative_site = "bogus")
  })
})
