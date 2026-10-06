# Pair each drone survey with the in situ biomass of its site-year, the cover
# biomass model's response, and notify the user of surveys left unpaired.

# Pure: returns list(data, unmatched). `data` is the paired surveys, in their
# original order and with their columns, plus `estimate`, `lower`, and `upper`;
# surveys whose site-year has no biomass are dropped, and their site-year keys
# are returned as `unmatched`, one per dropped survey. Biomass rows with no
# survey are ignored. Errors when no survey is paired, since there is then
# nothing to fit. Both inputs have passed .chk_cover_biomass_data().
join_cover_biomass <- function(data, biomass) {
  data_key <- site_year_key(data$site, data$year)
  idx <- match(data_key, site_year_key(biomass$site, biomass$year))
  unmatched <- is.na(idx)

  if (any(unmatched) && all(unmatched)) {
    cli::cli_abort(c(
      "No survey in {.arg data} has a site-year in {.arg biomass}.",
      i = "Surveys are paired with the in situ biomass by {.field site} and {.field year}."
    ))
  }

  out <- tibble::as_tibble(data)[!unmatched, , drop = FALSE]
  matched <- idx[!unmatched]
  out$estimate <- as.numeric(biomass$estimate[matched])
  out$lower <- as.numeric(biomass$lower[matched])
  out$upper <- as.numeric(biomass$upper[matched])
  list(data = out, unmatched = data_key[unmatched])
}

# Emit the unpaired-survey notice. Informational, so suppressed when
# progress = "none". `unmatched` is from join_cover_biomass(), one site-year key
# per dropped survey.
notify_cover_unmatched <- function(unmatched, progress = "bar") {
  n <- length(unmatched)
  if (identical(progress, "none") || n == 0L) {
    return(invisible(unmatched))
  }
  site_years <- unique(unmatched)
  cli::cli_inform(c(
    i = "{n} survey{?s} with no in situ biomass {cli::qty(n)}{?is/are} not fitted.",
    " " = "Site-year{?s}: {.val {site_years}}."
  ))
  invisible(unmatched)
}
