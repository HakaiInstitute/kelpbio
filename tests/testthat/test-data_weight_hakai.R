test_that("data_weight_hakai has the expected columns and passes validation", {
  expect_s3_class(data_weight_hakai, "data.frame")
  expect_named(data_weight_hakai, c("diameter_mm", "weight_kg", "site", "year"))
  expect_silent(kb_check_data_weight(data_weight_hakai))
})
