# Total wet biomass (kg) of each survey row, a D x N draws matrix: the expected
# biomass per m^2 of bed times the tide-corrected canopy area. The bed density is
# the cover model's own mean at a fully covered unit plot at zero tide height, so
# the model is stated once (.linpred/.epred); the floor therefore applies over the
# canopy area only. Both factors share each draw's site and year effects and
# bTide, and rows naming one new site or year share its sampled effect.
site_biomass_draws <- function(fit, grid, new_levels, representative_site) {
  bed <- grid[intersect(.group_vars(), names(grid))]
  bed$canopy_area_m2 <- 1
  bed$plot_area_m2 <- 1
  bed$tide_height_m <- 0
  density <- .epred(fit, .linpred(fit, bed, new_levels, representative_site))

  canopy <- grid$canopy_area_m2 * (1 + fit$draws$bTide * grid$tide_height_m)
  if ("site_area_m2" %in% names(grid)) {
    # min(site, canopy), written as (a + b - |a - b|) / 2 since pmin() does not
    # take an rvar.
    site <- grid$site_area_m2
    canopy <- (site + canopy - abs(site - canopy)) / 2
  }
  posterior::draws_of(density * canopy)
}
