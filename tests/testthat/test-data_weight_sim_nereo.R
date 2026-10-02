test_that("data_weight_sim_nereo has the expected columns and passes validation", {
  expect_s3_class(data_weight_sim_nereo, "data.frame")
  expect_named(
    data_weight_sim_nereo,
    c("diameter_mm", "weight_kg", "site", "year", "stipes_m2")
  )
  expect_silent(kb_check_data_weight_nereo(data_weight_sim_nereo))
})

test_that("data_weight_sim_nereo matches its documented format", {
  expect_gt(nrow(data_weight_sim_nereo), 0L)
  expect_equal(nlevels(data_weight_sim_nereo$site), 10L)
  expect_equal(nlevels(data_weight_sim_nereo$year), 4L)
  expect_true(all(data_weight_sim_nereo$diameter_mm > 0))
  expect_true(all(data_weight_sim_nereo$weight_kg > 0))
  expect_false(anyNA(data_weight_sim_nereo$stipes_m2))
})
