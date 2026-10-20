# `data` with `year` as a factor after `site`, a numeric year taking its
# character level.
with_year <- function(data) {
  data <- ids_as_character(tibble::as_tibble(data))
  data$year <- factor(data$year)
  dplyr::relocate(data, "year", .after = "site")
}
