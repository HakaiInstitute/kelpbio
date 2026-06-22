test_that("data_weight_hakai_nereo has the expected columns and passes validation", {
  expect_s3_class(data_weight_hakai_nereo, "data.frame")
  expect_named(data_weight_hakai_nereo, c("diameter", "weight", "site", "year"))
  expect_silent(kb_check_data_weight_nereo(data_weight_hakai_nereo))
})
