# "site:year" labels for paired site and year vectors, the key under which
# site-year facts (the observed combinations, recorded density) are stored.
site_year_key <- function(site, year) {
  paste(as.character(site), as.character(year), sep = ":")
}
