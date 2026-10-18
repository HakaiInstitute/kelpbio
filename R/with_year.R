# `data` with `year` taken from `date`, as a factor in date order, after `site`.
# The weight and size fits run at site-year resolution, so dates enter as years.
with_year <- function(data) {
  data <- tibble::as_tibble(data)
  data$year <- factor(date_year(data$date))
  dplyr::relocate(data, "year", .after = "site")
}
