test_that("predict wraps kb_predict_weight", {
  nd <- data.frame(diameter = c(20, 40))
  p <- predict(weight_fit, new_data = nd)
  expect_s3_class(p, "kb_predictions")
  # the deterministic "average" path matches kb_predict_weight directly
  expect_identical(
    predict(weight_fit, new_data = nd, new_levels = "average"),
    kb_predict_weight(weight_fit, new_data = nd, new_levels = "average")
  )
})
