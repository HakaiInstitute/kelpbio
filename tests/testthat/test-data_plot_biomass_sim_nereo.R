test_that("data_plot_biomass_sim_nereo has one row per surveyed site-year", {
  expect_named(
    data_plot_biomass_sim_nereo,
    c("site", "year", "estimate", "lower", "upper")
  )
  expect_identical(
    site_year_key(data_plot_biomass_sim_nereo$site, data_plot_biomass_sim_nereo$year),
    site_year_key(data_cover_biomass_sim_nereo$site, data_cover_biomass_sim_nereo$year)
  )
})

test_that("plot biomass composed from the bundled fits agrees with data_plot_biomass_sim_nereo", {
  skip_on_cran()
  withr::local_seed(1)
  composed <- kb_predict_plot_biomass(
    fit_weight_sim_nereo,
    fit_size_sim_nereo,
    fit_density_sim_nereo,
    progress = "none"
  )
  composed_key <- site_year_key(composed$site, composed$year)
  in_situ_key <- site_year_key(data_plot_biomass_sim_nereo$site, data_plot_biomass_sim_nereo$year)
  expect_true(all(in_situ_key %in% composed_key))
  ratio <- composed$estimate[match(in_situ_key, composed_key)] /
    data_plot_biomass_sim_nereo$estimate
  expect_gte(stats::median(ratio), 0.5)
  expect_lte(stats::median(ratio), 2)
})
