# The site and year indices of a grouped model's Stan data, coded by factor()
# level order, the order new_kb_fit() labels the effects with. Zero-row data
# (prior-only fits) take one level of each, so the effect vectors exist.
group_stan_data <- function(data) {
  site <- factor(data$site)
  year <- factor(data$year)
  list(
    n_site = max(1L, nlevels(site)),
    n_year = max(1L, nlevels(year)),
    site = as.integer(site),
    year = as.integer(year)
  )
}
