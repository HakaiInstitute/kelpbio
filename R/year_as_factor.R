# A numeric year names a level. As a factor it keeps numeric order, matches the
# fitted level of the same digits, and stays a discrete axis in plots.
year_as_factor <- function(x) {
  if ("year" %in% names(x) && is.numeric(x$year)) {
    x$year <- factor(x$year)
  }
  x
}
