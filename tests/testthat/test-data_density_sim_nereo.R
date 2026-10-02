test_that("data_density_sim_nereo has the expected columns and passes validation", {
  expect_s3_class(data_density_sim_nereo, "data.frame")
  expect_named(data_density_sim_nereo, c("stipes", "area_m2", "site", "year"))
  expect_silent(kb_check_data_density_nereo(data_density_sim_nereo))
  expect_equal(nlevels(data_density_sim_nereo$site), 10L)
  expect_equal(nlevels(data_density_sim_nereo$year), 4L)
})
