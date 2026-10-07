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
  # Every harvested site-year is density-surveyed, but not the reverse, and some
  # sites are never harvested.
  expect_true(all(weight %in% density))
  expect_lt(length(weight), length(density))
  expect_gt(
    length(setdiff(unique(data_density_sim_nereo$site), unique(data_weight_sim_nereo$site))),
    0L
  )
  # Size misses some density-surveyed site-years.
  expect_gt(length(setdiff(density, size)), 0L)
  # Every drone survey is paired with in situ plot biomass at a surveyed site-year.
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
