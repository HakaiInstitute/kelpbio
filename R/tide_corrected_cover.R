# Mirrors inst/stan/cover_biomass.stan: tide-corrected canopy, capped at the
# plot area, as a proportion of it.
tide_corrected_cover <- function(grid, tide_height_slope) {
  canopy <- tide_corrected_canopy(
    grid$canopy_area_m2,
    grid$tide_height_m,
    tide_height_slope
  )
  rvar_pmin(canopy, grid$plot_area_m2) / grid$plot_area_m2
}
