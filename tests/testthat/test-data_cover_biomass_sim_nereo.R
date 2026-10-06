test_that("data_cover_biomass_sim_nereo and data_plot_biomass_sim_nereo pass validation together", {
  expect_s3_class(data_cover_biomass_sim_nereo, "data.frame")
  expect_named(
    data_cover_biomass_sim_nereo,
    c("site", "year", "canopy_area_m2", "plot_area_m2", "tide_height_m")
  )
  expect_named(
    data_plot_biomass_sim_nereo,
    c("site", "year", "estimate", "lower", "upper")
  )
  expect_silent(
    kb_check_data_cover_biomass_nereo(data_cover_biomass_sim_nereo, data_plot_biomass_sim_nereo)
  )
  expect_equal(nlevels(data_cover_biomass_sim_nereo$site), 10L)
  expect_equal(nlevels(data_cover_biomass_sim_nereo$year), 4L)
})
