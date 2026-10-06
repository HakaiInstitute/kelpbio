test_that("data_cover_biomass_sim_macro and data_plot_biomass_sim_macro pass validation together", {
  expect_s3_class(data_cover_biomass_sim_macro, "data.frame")
  expect_named(
    data_cover_biomass_sim_macro,
    c("site", "year", "canopy_area_m2", "plot_area_m2", "tide_height_m")
  )
  expect_named(
    data_plot_biomass_sim_macro,
    c("site", "year", "estimate", "lower", "upper")
  )
  expect_silent(
    kb_check_data_cover_biomass_macro(data_cover_biomass_sim_macro, data_plot_biomass_sim_macro)
  )
  expect_equal(nlevels(data_cover_biomass_sim_macro$site), 10L)
  expect_equal(nlevels(data_cover_biomass_sim_macro$year), 4L)
})
