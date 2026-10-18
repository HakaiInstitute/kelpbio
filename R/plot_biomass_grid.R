# One row per site-year in the density fit's data.
plot_biomass_grid <- function(weight, size, density) {
  data <- tibble::as_tibble(density$data)
  grid <- dplyr::distinct(data, .data$site, .data$year)
  grid$site <- factor(as.character(grid$site), levels = density$meta$site_levels)
  grid$year <- factor(as.character(grid$year), levels = density$meta$year_levels)
  grid <- dplyr::arrange(grid, .data$site, .data$year)

  grid$weight_support <- data_support(weight, grid$site, grid$year)
  grid$size_support <- data_support(size, grid$site, grid$year)
  grid
}
