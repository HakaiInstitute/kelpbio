# One row per site-year in the density fit's data. `stipes_m2` is the observed
# density (total count over total area) under the name the Nereocystis weight
# model's density covariate reads; other weight fits ignore it.
plot_biomass_grid <- function(weight, size, density) {
  data <- tibble::as_tibble(density$data)
  key <- site_year_key(data$site, data$year)
  count <- tapply(data[[density$meta$response]], key, sum)
  area <- tapply(data[[density$meta$offset]], key, sum)

  grid <- dplyr::distinct(data, .data$site, .data$year)
  grid$site <- factor(as.character(grid$site), levels = density$meta$site_levels)
  grid$year <- factor(as.character(grid$year), levels = density$meta$year_levels)
  grid <- dplyr::arrange(grid, .data$site, .data$year)

  grid_key <- site_year_key(grid$site, grid$year)
  grid$weight_support <- data_support(weight, grid$site, grid$year)
  grid$size_support <- data_support(size, grid$site, grid$year)
  grid$stipes_m2 <- unname(count[grid_key] / area[grid_key])
  grid
}
