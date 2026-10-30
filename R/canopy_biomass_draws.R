# Total wet biomass (kg) per row, D x N: the bed biomass per m^2 (the
# calibration's mean at a fully covered unit plot at zero tide height, so the
# floor applies over the canopy only) times the tide-corrected canopy, capped at
# `classified_area_m2`. The presence probability is left out: at full cover it
# is 1 for a fit whose data identify the presence slope, and the totals should
# not depend on it where they do not (HakaiInstitute/kelpbio#66).
canopy_biomass_draws <- function(fit, grid, new_levels, representative_site) {
  bed <- grid[intersect(.group_vars(), names(grid))]
  bed$canopy_area_m2 <- 1
  bed$plot_area_m2 <- 1
  bed$canopy_tide_height_m <- 0
  density <- exp(.linpred(fit, bed, new_levels, representative_site))

  canopy <- tide_corrected_canopy(
    grid$canopy_area_m2,
    grid$canopy_tide_height_m,
    fit$draws$tide_height_slope,
    cap = grid$classified_area_m2
  )
  posterior::draws_of(density * canopy)
}
