test_that("the grid has one row per density site-year with its observed density", {
  grid <- plot_biomass_grid(weight_fit, size_nereo_fit, density_nereo_fit)
  data <- density_nereo_fit$data
  key <- site_year_key(data$site, data$year)
  expect_equal(nrow(grid), length(unique(key)))
  expect_named(grid, c("site", "year", "weight_support", "size_support", "stipes_m2"))
  k <- site_year_key(grid$site[1], grid$year[1])
  expect_equal(
    grid$stipes_m2[1],
    sum(data$stipes[key == k]) / sum(data$area_m2[key == k])
  )
  expect_identical(levels(grid$site), density_nereo_fit$meta$site_levels)
})

test_that("the support columns follow the weight and size fits' data", {
  grid <- plot_biomass_grid(weight_macro_fit, size_macro_fit, density_macro_fit)
  expect_identical(
    grid$weight_support,
    data_support(weight_macro_fit, grid$site, grid$year)
  )
  expect_identical(
    grid$size_support,
    data_support(size_macro_fit, grid$site, grid$year)
  )
})
