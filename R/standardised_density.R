# Each row takes its own density, then its site-year's recorded density, then
# the fitted mean (0). Shared by fitting and prediction so both use one rule.
standardised_density <- function(grid, on, mean, sd, levels) {
  n <- nrow(grid)
  if (!isTRUE(on)) {
    return(rep(0, n))
  }
  density <- if ("stipes_m2" %in% names(grid)) {
    as.numeric(grid$stipes_m2)
  } else {
    rep(NA_real_, n)
  }
  if (all(c("site", "year") %in% names(grid))) {
    recorded <- unname(levels[site_year_key(grid$site, grid$year)])
    density <- dplyr::coalesce(density, recorded)
  }
  z <- (density - mean) / sd
  z[is.na(z)] <- 0
  z
}
