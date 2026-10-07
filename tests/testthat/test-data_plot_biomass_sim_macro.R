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

test_that("plot biomass composed from the bundled fits agrees with data_plot_biomass_sim_macro", {
  skip_on_cran()
  withr::local_seed(1)
  composed <- kb_predict_plot_biomass(
    fit_weight_sim_macro,
    fit_size_sim_macro,
    fit_density_sim_macro,
    progress = "none"
  )
  composed_key <- site_year_key(composed$site, composed$year)
  in_situ_key <- site_year_key(data_plot_biomass_sim_macro$site, data_plot_biomass_sim_macro$year)
  expect_true(all(in_situ_key %in% composed_key))
  ratio <- composed$estimate[match(in_situ_key, composed_key)] /
    data_plot_biomass_sim_macro$estimate
  expect_gte(stats::median(ratio), 0.5)
  expect_lte(stats::median(ratio), 2)
})
