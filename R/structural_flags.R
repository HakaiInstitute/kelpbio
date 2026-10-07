# Only the Nereocystis weight model records the flag; its absence reads as FALSE.
.density_on <- function(fit) {
  isTRUE(fit$meta$density_on)
}

.floor_on <- function(fit) {
  identical(fit$meta$form, "packard_floor")
}

.site_year_on <- function(fit) {
  isTRUE(fit$meta$site_year_on)
}
