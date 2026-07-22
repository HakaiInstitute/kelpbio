# Determine the site:year random-effect structure from the data, and notify the
# user. The site:year effect is kept whenever more than one year is present (the
# regularizing prior shrinks it when weakly supported); it is dropped only when
# the year dimension is degenerate (fewer than two years), where the interaction
# is structurally confounded with the site effect. When years exist but no site
# was sampled in more than one year the design is aliased: the effect is kept but
# the site vs site:year split is not identifiable and reflects the prior.

# Pure: returns list(on, aliased). Uses distinct values present, so unused factor
# levels do not affect the result.
site_year_structure <- function(data) {
  year <- as.character(data$year)
  site <- as.character(data$site)
  n_year <- length(unique(year))
  years_per_site <- tapply(year, site, function(x) length(unique(x)))
  any_multiyear_site <- any(years_per_site > 1)
  on <- n_year > 1
  list(on = on, aliased = on && !isTRUE(any_multiyear_site))
}

# Emit the structural notice. The aliasing warning always shows; the drop notice
# is informational and suppressed when progress = "none".
notify_site_year <- function(status, progress = "bar") {
  if (status$aliased) {
    cli::cli_warn(c(
      "Site and site:year effects are not separately identifiable: no site was sampled in more than one year.",
      i = "The term is retained and predictions are unaffected, but do not interpret the site and site:year contributions separately."
    ))
  } else if (!status$on && !identical(progress, "none")) {
    cli::cli_inform(c(
      i = "The site:year effect is omitted: fewer than two years are present."
    ))
  }
  invisible(status)
}
