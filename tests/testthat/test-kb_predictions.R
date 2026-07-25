test_that("kb_predictions carries column-role metadata", {
  p <- kb_predict_weight_by(weight_fit, by = "site")
  expect_s3_class(p, "kb_predictions")
  expect_s3_class(p, "tbl_df")
  expect_equal(attr(p, "kb_predictor"), "diameter")
  expect_equal(attr(p, "kb_response"), "weight")
  expect_equal(attr(p, "kb_group_vars"), "site")
})

test_that("print.kb_predictions shows the metadata header", {
  p <- kb_predict_weight_by(weight_fit, by = "site")
  expect_output(print(p), "predictor: diameter")
  expect_output(print(p), "by: site")
})
