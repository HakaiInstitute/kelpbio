# Site:year effect structure: list(on, aliased). site:year separates from the
# site effect only if some site spans several years, and from the year effect
# only if some year spans several sites (rationale in the fitting spec).
site_year_structure <- function(data) {
  year <- as.character(data$year)
  site <- as.character(data$site)
  on <- length(unique(year)) > 1
  if (!on) {
    return(list(on = FALSE, aliased = character(0)))
  }
  years_per_site <- tapply(year, site, function(x) length(unique(x)))
  sites_per_year <- tapply(site, year, function(x) length(unique(x)))
  aliased <- c(
    if (!any(years_per_site > 1)) "site",
    if (!any(sites_per_year > 1)) "year"
  )
  list(on = TRUE, aliased = as.character(aliased))
}

# The aliasing warning always shows; the drop notice is silent when
# progress = "none".
notify_site_year <- function(status, progress = "bar") {
  if (length(status$aliased)) {
    reasons <- c(
      site = "no site was sampled in more than one year",
      year = "no year had more than one site sampled"
    )[status$aliased]
    effects <- status$aliased
    cli::cli_warn(c(
      "The site:year effect is not separately identifiable from the {effects} effect{?s}: {reasons}.",
      i = "The term is retained and predictions are unaffected, but do not interpret the site:year contribution separately from the {effects} effect{?s}."
    ))
  } else if (!status$on && !identical(progress, "none")) {
    cli::cli_inform(c(
      i = "The site:year effect is omitted: fewer than two years are present."
    ))
  }
  invisible(status)
}
