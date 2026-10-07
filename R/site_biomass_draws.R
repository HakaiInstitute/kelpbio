# Total wet biomass (kg) per survey row, D x N: the bed density (the cover
# model's mean at a fully covered unit plot at zero tide height, so the floor
# applies over the canopy only) times the tide-corrected canopy area.
site_biomass_draws <- function(fit, grid, new_levels, representative_site) {
  bed <- grid[intersect(.group_vars(), names(grid))]
  bed$canopy_area_m2 <- 1
  bed$plot_area_m2 <- 1
  bed$tide_height_m <- 0
  density <- .epred(fit, .linpred(fit, bed, new_levels, representative_site))

  canopy <- grid$canopy_area_m2 * (1 + fit$draws$tide_height_slope * grid$tide_height_m)
  if ("site_area_m2" %in% names(grid)) {
    # pmin() as arithmetic, since it does not take an rvar.
    site <- grid$site_area_m2
    canopy <- (site + canopy - abs(site - canopy)) / 2
  }
  posterior::draws_of(density * canopy)
}
