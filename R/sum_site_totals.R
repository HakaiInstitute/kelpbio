# Per-draw sums of the totals within `sum_by` groups (character(0) sums all),
# returning the group keys and a D x G matrix. Summing draws, not summaries,
# keeps the limits of a regional total correct.
sum_site_totals <- function(grid, totals, sum_by) {
  keys <- tibble::as_tibble(grid)[sum_by]
  if (length(sum_by)) {
    groups <- dplyr::arrange(
      dplyr::distinct(keys),
      dplyr::pick(dplyr::everything())
    )
    id <- match(do.call(paste, c(keys, sep = "\r")), do.call(paste, c(groups, sep = "\r")))
  } else {
    groups <- tibble::tibble(.rows = 1L)
    id <- rep(1L, nrow(grid))
  }
  warn_overlapping_surveys(grid, id, groups)
  # rowsum() orders by ascending id, which is the order of `groups`.
  list(groups = groups, draws = t(rowsum(t(totals), id)))
}

# Two rows for one site-year in a group are two totals over the same mapped
# canopy, so their sum double counts.
warn_overlapping_surveys <- function(grid, id, groups) {
  key <- site_year_key(grid$site, grid$year)
  repeated <- unique(key[duplicated(paste(id, key))])
  if (length(repeated)) {
    cli::cli_warn(c(
      "Some {.arg sum_by} groups hold more than one row for a site-year, so their totals overlap.",
      i = "Repeated: {.val {repeated}}."
    ))
  }
  invisible(NULL)
}
