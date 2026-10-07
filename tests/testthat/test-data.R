test_that("data_carbon_sim_macro has the expected columns and passes validation", {
  expect_s3_class(data_carbon_sim_macro, "data.frame")
  expect_named(data_carbon_sim_macro, c("sample_mass_mg", "carbon_mass_ug"))
  expect_silent(kb_check_data_carbon_macro(data_carbon_sim_macro))
})

test_that("data_carbon_sim_nereo has the expected columns and passes validation", {
  expect_s3_class(data_carbon_sim_nereo, "data.frame")
  expect_named(data_carbon_sim_nereo, c("sample_mass_mg", "carbon_mass_ug"))
  expect_silent(kb_check_data_carbon_nereo(data_carbon_sim_nereo))
})

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

test_that("data_density_sim_macro has the expected columns and passes validation", {
  expect_s3_class(data_density_sim_macro, "data.frame")
  expect_named(data_density_sim_macro, c("plants", "area_m2", "site", "year"))
  expect_silent(kb_check_data_density_macro(data_density_sim_macro))
  expect_equal(nlevels(data_density_sim_macro$site), 10L)
  expect_equal(nlevels(data_density_sim_macro$year), 4L)
})

test_that("data_density_sim_nereo has the expected columns and passes validation", {
  expect_s3_class(data_density_sim_nereo, "data.frame")
  expect_named(data_density_sim_nereo, c("stipes", "area_m2", "site", "year"))
  expect_silent(kb_check_data_density_nereo(data_density_sim_nereo))
  expect_equal(nlevels(data_density_sim_nereo$site), 10L)
  expect_equal(nlevels(data_density_sim_nereo$year), 4L)
})

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

test_that("data_size_sim_macro has the expected columns and passes validation", {
  expect_s3_class(data_size_sim_macro, "data.frame")
  expect_named(data_size_sim_macro, c("fronds", "site", "year"))
  expect_silent(kb_check_data_size_macro(data_size_sim_macro))
  expect_equal(nlevels(data_size_sim_macro$site), 10L)
  expect_equal(nlevels(data_size_sim_macro$year), 4L)
})

test_that("data_size_sim_nereo has the expected columns and passes validation", {
  expect_s3_class(data_size_sim_nereo, "data.frame")
  expect_named(data_size_sim_nereo, c("diameter_mm", "site", "year"))
  expect_silent(kb_check_data_size_nereo(data_size_sim_nereo))
  expect_equal(nlevels(data_size_sim_nereo$site), 10L)
  expect_equal(nlevels(data_size_sim_nereo$year), 4L)
})

test_that("data_weight_sim_macro has the expected columns and passes validation", {
  expect_s3_class(data_weight_sim_macro, "data.frame")
  expect_named(data_weight_sim_macro, c("fronds", "weight_kg", "site", "year"))
  expect_silent(kb_check_data_weight_macro(data_weight_sim_macro))
})

test_that("data_weight_sim_macro matches its documented format", {
  expect_gt(nrow(data_weight_sim_macro), 0L)
  expect_equal(nlevels(data_weight_sim_macro$site), 10L)
  expect_equal(nlevels(data_weight_sim_macro$year), 4L)
  expect_true(all(data_weight_sim_macro$fronds > 0))
  expect_true(all(
    data_weight_sim_macro$fronds == round(data_weight_sim_macro$fronds)
  ))
  expect_true(all(data_weight_sim_macro$weight_kg > 0))
})

test_that("the macro data sources cover different site-years", {
  key <- function(data) unique(site_year_key(data$site, data$year))
  weight <- key(data_weight_sim_macro)
  size <- key(data_size_sim_macro)
  density <- key(data_density_sim_macro)
  expect_true(all(weight %in% density))
  expect_lt(length(weight), length(density))
  expect_gt(
    length(setdiff(unique(data_density_sim_macro$site), unique(data_weight_sim_macro$site))),
    0L
  )
  expect_gt(length(setdiff(density, size)), 0L)
  expect_true(all(key(data_cover_biomass_sim_macro) %in% key(data_plot_biomass_sim_macro)))
  expect_true(all(key(data_cover_biomass_sim_macro) %in% density))
})

test_that("data_weight_sim_nereo has the expected columns and passes validation", {
  expect_s3_class(data_weight_sim_nereo, "data.frame")
  expect_named(
    data_weight_sim_nereo,
    c("diameter_mm", "weight_kg", "site", "year", "stipes_m2")
  )
  expect_silent(kb_check_data_weight_nereo(data_weight_sim_nereo))
})

test_that("data_weight_sim_nereo matches its documented format", {
  expect_gt(nrow(data_weight_sim_nereo), 0L)
  expect_equal(nlevels(data_weight_sim_nereo$site), 10L)
  expect_equal(nlevels(data_weight_sim_nereo$year), 4L)
  expect_true(all(data_weight_sim_nereo$diameter_mm > 0))
  expect_true(all(data_weight_sim_nereo$weight_kg > 0))
  expect_false(anyNA(data_weight_sim_nereo$stipes_m2))
})

test_that("the nereo data sources cover different site-years", {
  key <- function(data) unique(site_year_key(data$site, data$year))
  weight <- key(data_weight_sim_nereo)
  size <- key(data_size_sim_nereo)
  density <- key(data_density_sim_nereo)
  expect_true(all(weight %in% density))
  expect_lt(length(weight), length(density))
  expect_gt(
    length(setdiff(unique(data_density_sim_nereo$site), unique(data_weight_sim_nereo$site))),
    0L
  )
  expect_gt(length(setdiff(density, size)), 0L)
  expect_true(all(key(data_cover_biomass_sim_nereo) %in% key(data_plot_biomass_sim_nereo)))
  expect_true(all(key(data_cover_biomass_sim_nereo) %in% density))
})

test_that("the harvested site-years carry the stipe density observed in the density data", {
  density <- data_density_sim_nereo
  key <- site_year_key(density$site, density$year)
  observed <- tapply(density$stipes, key, sum) / tapply(density$area_m2, key, sum)
  weight_key <- site_year_key(data_weight_sim_nereo$site, data_weight_sim_nereo$year)
  expect_equal(
    data_weight_sim_nereo$stipes_m2,
    round(as.vector(observed[weight_key]), 2)
  )
})

test_that("data_wetdry_sim_macro has the expected columns and passes validation", {
  expect_s3_class(data_wetdry_sim_macro, "data.frame")
  expect_named(data_wetdry_sim_macro, c("wet_mass_g", "dry_mass_g"))
  expect_silent(kb_check_data_wetdry_macro(data_wetdry_sim_macro))
})

test_that("data_wetdry_sim_nereo has the expected columns and passes validation", {
  expect_s3_class(data_wetdry_sim_nereo, "data.frame")
  expect_named(data_wetdry_sim_nereo, c("wet_mass_g", "dry_mass_g"))
  expect_silent(kb_check_data_wetdry_nereo(data_wetdry_sim_nereo))
})
