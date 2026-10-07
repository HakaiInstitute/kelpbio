# Mirrors inst/stan/cover_biomass.stan. The cap at the plot area is pmin()
# written as arithmetic, since pmin() does not take an rvar.
tide_corrected_cover <- function(grid, tide_height_slope) {
  plot <- grid$plot_area_m2
  canopy <- grid$canopy_area_m2 * (1 + tide_height_slope * grid$tide_height_m)
  (plot + canopy - abs(plot - canopy)) / 2 / plot
}
