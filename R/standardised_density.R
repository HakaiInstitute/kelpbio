# Standardised density for each row of a grid, resolved in order: the row's own
# density value, then the recorded density of its site-year, then the fitted mean
# (standardised value 0). Shared by fitting (assemble_weight_nereo_data()) and
# prediction (.linpred.kb_fit_weight_nereo()), so both use one rule. A zero
# vector when the density term is off.
standardised_density <- function(grid, on, mean, sd, levels) {
  n <- nrow(grid)
  if (!isTRUE(on)) {
    return(rep(0, n))
  }
  density <- if ("density" %in% names(grid)) {
    as.numeric(grid$density)
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
