# Pair each drone survey with its site-year's in situ biomass. Returns
# list(data, unmatched): surveys with no biomass are dropped and their site-year
# keys returned, one per dropped survey. Errors when no survey is paired.
join_cover_biomass <- function(data, biomass, call = rlang::caller_env()) {
  data_key <- site_year_key(data$site, data$year)
  idx <- match(data_key, site_year_key(biomass$site, biomass$year))
  unmatched <- is.na(idx)

  if (any(unmatched) && all(unmatched)) {
    cli::cli_abort(c(
      "No survey in {.arg data} has a site-year in {.arg biomass}.",
      i = "Surveys are paired with the in situ biomass by {.field site} and {.field year}."
    ), call = call)
  }

  out <- tibble::as_tibble(data)[!unmatched, , drop = FALSE]
  matched <- idx[!unmatched]
  out$estimate <- as.numeric(biomass$estimate[matched])
  out$lower <- as.numeric(biomass$lower[matched])
  out$upper <- as.numeric(biomass$upper[matched])
  list(data = out, unmatched = data_key[unmatched])
}

# Silent when progress = "none".
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
