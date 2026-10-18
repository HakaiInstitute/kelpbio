.floor_on <- function(fit) {
  identical(fit$meta$form, "packard_floor")
}

.site_year_on <- function(fit) {
  isTRUE(fit$meta$site_year_on)
}
