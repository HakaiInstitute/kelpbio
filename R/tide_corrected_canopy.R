# Canopy area corrected to zero tide height, as in inst/stan/cover_biomass.stan.
# `tide_height_slope` may be an rvar.
tide_corrected_canopy <- function(canopy_area_m2, tide_height_m, tide_height_slope) {
  canopy_area_m2 * (1 + tide_height_slope * tide_height_m)
}
