test_that("data_size_sim_macro has the expected columns and passes validation", {
  expect_s3_class(data_size_sim_macro, "data.frame")
  expect_named(data_size_sim_macro, c("fronds", "site", "year"))
  expect_silent(kb_check_data_size_macro(data_size_sim_macro))
  expect_equal(nlevels(data_size_sim_macro$site), 10L)
  expect_equal(nlevels(data_size_sim_macro$year), 4L)
})
