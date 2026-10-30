# Mirrors inst/stan/cover_calibration.stan: tide-corrected canopy, capped at the
# plot area, as a proportion of it.
tide_corrected_cover <- function(grid, tide_height_slope) {
  canopy <- tide_corrected_canopy(
    grid$canopy_area_m2,
    grid$canopy_tide_height_m,
    tide_height_slope,
    cap = grid$plot_area_m2
  )
  canopy / grid$plot_area_m2
}

# The cover calibration's log odds that a plot holds plants (rvar, one element
# per row of `grid`), as in inst/stan/cover_calibration.stan: the slope is per
# percentage point of cover.
presence_logit <- function(fit, grid) {
  draws <- fit$draws
  cover <- tide_corrected_cover(grid, draws$tide_height_slope)
  draws$presence_intercept + draws$presence_cover_slope * 100 * cover
}
