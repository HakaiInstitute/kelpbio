test_that("data_density_sim_macro has the expected columns and passes validation", {
  expect_s3_class(data_density_sim_macro, "data.frame")
  expect_named(data_density_sim_macro, c("plants", "area_m2", "site", "year"))
  expect_silent(kb_check_data_density_macro(data_density_sim_macro))
  expect_equal(nlevels(data_density_sim_macro$site), 10L)
  expect_equal(nlevels(data_density_sim_macro$year), 4L)
})
