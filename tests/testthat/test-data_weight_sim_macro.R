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
  # Every harvested site-year is density-surveyed, but not the reverse, and some
  # sites are never harvested.
  expect_true(all(weight %in% density))
  expect_lt(length(weight), length(density))
  expect_gt(
    length(setdiff(unique(data_density_sim_macro$site), unique(data_weight_sim_macro$site))),
    0L
  )
  # Size misses some density-surveyed site-years.
  expect_gt(length(setdiff(density, size)), 0L)
  # Every drone survey is paired with in situ plot biomass at a surveyed site-year.
  expect_true(all(key(data_cover_biomass_sim_macro) %in% key(data_plot_biomass_sim_macro)))
  expect_true(all(key(data_cover_biomass_sim_macro) %in% density))
})
