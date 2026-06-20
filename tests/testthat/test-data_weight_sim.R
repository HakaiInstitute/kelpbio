test_that("data_weight_sim has the expected columns and passes validation", {
  expect_s3_class(data_weight_sim, "data.frame")
  expect_named(data_weight_sim, c("diameter_mm", "weight_kg", "site", "year"))
  expect_silent(kb_check_data_weight(data_weight_sim))
})
