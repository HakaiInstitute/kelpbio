# One representative_site per fit with site effects: a character vector applies
# to every fit, a list gives each fit its own (NULL where it names none).
representative_sites <- function(representative_site, fits = c("weight", "size")) {
  out <- lapply(fits, function(fit) {
    if (is.list(representative_site)) representative_site[[fit]] else representative_site
  })
  names(out) <- fits
  out
}
