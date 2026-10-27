# Canopy area corrected to zero tide height, as in
# inst/stan/cover_calibration.stan: `tide_height_slope` is the share of the
# zero-tide canopy lost per metre of tide, so the canopy seen at a tide height
# is divided by one minus that share, and capped at `cap`. Past one over the
# slope the division has no finite value, so positive canopy takes the cap, its
# limit as the share seen falls to zero; zero canopy stays zero.
# `tide_height_slope` is an rvar of draws; the result is an rvar of length N.
tide_corrected_canopy <- function(canopy_area_m2, canopy_tide_height_m, tide_height_slope, cap) {
  slope <- as.vector(posterior::draws_of(tide_height_slope))
  n_draw <- length(slope)
  n <- length(canopy_area_m2)
  corrected <- cap_canopy(
    matrix(canopy_area_m2, n_draw, n, byrow = TRUE),
    1 - outer(slope, canopy_tide_height_m),
    matrix(cap, n_draw, n, byrow = TRUE)
  )
  posterior::rvar(corrected, nchains = posterior::nchains(tide_height_slope))
}

cap_canopy <- function(canopy, seen, cap) {
  corrected <- ifelse(seen > 0, pmin(canopy / seen, cap), cap)
  corrected[canopy == 0] <- 0
  corrected
}

# The upper bound of the tide slope's support, as declared for
# `tide_height_slope` in inst/stan/cover_calibration.stan; keep the two equal.
TIDE_SLOPE_UPPER <- 0.5

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
