# The data a fit has for each site-year, from most to least local: "site-year",
# "site, year" (both but not together), "site", "year", or "none".
data_support <- function(fit, site, year) {
  site <- as.character(site)
  year <- as.character(year)
  has_site <- site %in% fit$meta$site_levels
  has_year <- year %in% fit$meta$year_levels
  dplyr::case_when(
    site_year_key(site, year) %in% fit$meta$site_year_levels ~ "site-year",
    has_site & has_year ~ "site, year",
    has_site ~ "site",
    has_year ~ "year",
    .default = "none"
  )
}

# data_support() without "site-year", since the cover model has no site:year
# effect.
cover_support <- function(fit, site, year) {
  support <- data_support(fit, site, year)
  support[support == "site-year"] <- "site, year"
  support
}

# Adds the fit's support column (`weight_support`, `size_support`, or
# `cover_support`) when the rows name both a site and a year.
with_support <- function(grid, fit) {
  if (!all(c("site", "year") %in% names(grid))) {
    return(grid)
  }
  if (inherits(fit, "kb_fit_cover_calibration")) {
    grid$cover_support <- cover_support(fit, grid$site, grid$year)
  } else if (inherits(fit, "kb_fit_weight")) {
    grid$weight_support <- data_support(fit, grid$site, grid$year)
  } else {
    grid$size_support <- data_support(fit, grid$site, grid$year)
  }
  grid
}
