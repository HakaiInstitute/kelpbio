# Only the Nereocystis weight model records the flag; its absence reads as FALSE.
.density_on <- function(fit) {
  isTRUE(fit$meta$density_on)
}

.floor_on <- function(fit) {
  identical(fit$meta$form, "packard_floor")
}

# A fit that omitted the site:year effect still holds its prior-only draws,
# which no surface may present as estimated.
.site_year_on <- function(fit) {
  isTRUE(fit$meta$site_year_on)
}
