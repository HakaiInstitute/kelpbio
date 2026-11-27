# The main effects the site:year effect cannot be separated from: the site
# effect unless some site spans several years, the year effect unless some year
# spans several sites (rationale in the fitting spec). Zero-row data (a
# prior-only fit) have nothing to alias.
site_year_aliasing <- function(data) {
  if (!nrow(data)) {
    return(character(0))
  }
  year <- as.character(data$year)
  site <- as.character(data$site)
  years_per_site <- tapply(year, site, function(x) length(unique(x)))
  sites_per_year <- tapply(site, year, function(x) length(unique(x)))
  as.character(c(
    if (!any(years_per_site > 1)) "site",
    if (!any(sites_per_year > 1)) "year"
  ))
}

notify_site_year <- function(aliased) {
  if (length(aliased)) {
    reasons <- c(
      site = "no site was sampled in more than one year",
      year = "no year had more than one site sampled"
    )[aliased]
    cli::cli_warn(c(
      "The site:year effect cannot be separated from the {aliased} effect{?s}: {reasons}.",
      i = "Estimates for the sampled site-years are unaffected, but the {aliased} effects, and predictions for other site-years or new sites and years, rest on the {.code sd_site_year} prior.",
      i = "Check the sensitivity to that prior with {.fn kb_sensitivity}, and narrow it through {.arg priors} if little site:year variation is expected."
    ))
  }
  invisible(aliased)
}
