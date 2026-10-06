test_that("data_plot_biomass_sim_macro has one row per surveyed site-year", {
  expect_named(
    data_plot_biomass_sim_macro,
    c("site", "year", "estimate", "lower", "upper")
  )
  expect_identical(
    site_year_key(data_plot_biomass_sim_macro$site, data_plot_biomass_sim_macro$year),
    site_year_key(data_cover_biomass_sim_macro$site, data_cover_biomass_sim_macro$year)
  )
})
