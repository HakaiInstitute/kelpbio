test_that("data_weight_sim_macro has the expected columns and passes validation", {
  expect_s3_class(data_weight_sim_macro, "data.frame")
  expect_named(data_weight_sim_macro, c("fronds", "weight", "site", "year"))
  expect_silent(kb_check_data_weight_macro(data_weight_sim_macro))
})

test_that("data_weight_sim_macro matches its documented format", {
  expect_gt(nrow(data_weight_sim_macro), 0L)
  expect_equal(nlevels(data_weight_sim_macro$site), 10L)
  expect_equal(nlevels(data_weight_sim_macro$year), 4L)
  expect_true(all(data_weight_sim_macro$fronds > 0))
  expect_true(all(data_weight_sim_macro$fronds == round(data_weight_sim_macro$fronds)))
  expect_true(all(data_weight_sim_macro$weight > 0))
})
