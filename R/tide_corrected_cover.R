# Tide-corrected proportional canopy cover of each grid row, a posterior rvar:
# the canopy area scaled up by tide_height_slope per metre of tide height, capped at the
# plot area, over the plot area. Mirrors inst/stan/cover_biomass.stan. The cap is
# written as (a + b - |a - b|) / 2, since pmin() does not take an rvar while +, -
# and abs() do.
tide_corrected_cover <- function(grid, b_tide) {
  plot <- grid$plot_area_m2
  canopy <- grid$canopy_area_m2 * (1 + b_tide * grid$tide_height_m)
  (plot + canopy - abs(plot - canopy)) / 2 / plot
}
