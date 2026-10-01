test_that("data_size_sim_nereo has the expected columns and passes validation", {
  expect_s3_class(data_size_sim_nereo, "data.frame")
  expect_named(data_size_sim_nereo, c("diameter", "site", "year"))
  expect_silent(kb_check_data_size_nereo(data_size_sim_nereo))
  expect_equal(nlevels(data_size_sim_nereo$site), 10L)
  expect_equal(nlevels(data_size_sim_nereo$year), 4L)
})
