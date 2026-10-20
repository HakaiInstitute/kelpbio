# Total wet biomass (kg) per row, D x N: the bed biomass per m^2 (the calibration's mean at a fully covered
# unit plot at zero tide height, so the floor applies over the canopy only)
# times the tide-corrected canopy, capped at `site_area_m2` where given.
canopy_biomass_draws <- function(fit, grid, new_levels, representative_site) {
  bed <- grid[intersect(.group_vars(), names(grid))]
  bed$canopy_area_m2 <- 1
  bed$plot_area_m2 <- 1
  bed$tide_height_m <- 0
  density <- .epred(fit, .linpred(fit, bed, new_levels, representative_site))

  canopy <- tide_corrected_canopy(
    grid$canopy_area_m2,
    grid$tide_height_m,
    fit$draws$tide_height_slope
  )
  if ("site_area_m2" %in% names(grid)) {
    canopy <- rvar_pmin(canopy, grid$site_area_m2)
  }
  posterior::draws_of(density * canopy)
}
