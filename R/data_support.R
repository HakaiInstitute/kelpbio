# The data a fit has for each site-year, from most to least local: the
# site-year itself ("site-year"), its site and its year but not together
# ("site, year"), only its site ("site") or year ("year"), or neither ("none").
# Says which effects a prediction there takes from the fit and which it borrows.
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
