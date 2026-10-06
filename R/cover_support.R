# The data a cover biomass fit has for each row's site and year: "site, year",
# "site", "year", or "none", as data_support() but without "site-year", since the
# cover model has no site:year effect.
cover_support <- function(fit, site, year) {
  support <- data_support(fit, site, year)
  support[support == "site-year"] <- "site, year"
  support
}
