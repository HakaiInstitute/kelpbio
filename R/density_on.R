# Whether a fit includes the density term. A fit made before the term existed has
# no meta$density_on and was fitted without it, so a missing flag reads as FALSE.
.density_on <- function(fit) {
  isTRUE(fit$meta$density_on)
}
