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
