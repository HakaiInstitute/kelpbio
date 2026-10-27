# The exhaustive set of grouping factors (no month effect). Intercept-only
# models have empty level sets, so their level checks pass trivially.
.group_vars <- function() {
  c("site", "year")
}

.fit_levels <- function(fit, nm) {
  fit$meta[[paste0(nm, "_levels")]]
}

validate_by <- function(by) {
  if (is.null(by)) {
    by <- character(0)
  }
  chk::chk_character(by)
  valid <- .group_vars()
  bad <- setdiff(by, valid)
  if (length(bad)) {
    cli::cli_abort(c(
      "Invalid {.arg by} value{?s}: {.val {bad}}.",
      i = "Available grouping factors: {.val {valid}}."
    ))
  }
  by
}

site_year_key <- function(site, year) {
  paste(as.character(site), as.character(year), sep = ":")
}

# The text of a `year` or `survey_id` value: the type of the fits' levels, and
# the one form every check and join compares. Whole numbers are written in
# full, never in scientific notation ("100000", not "1e+05").
id_text <- function(x) {
  if (!is.numeric(x) || inherits(x, "integer64")) {
    return(as.character(x))
  }
  whole <- !is.na(x) & is.finite(x) & x == round(x)
  out <- as.character(x)
  out[whole] <- sprintf("%.0f", x[whole])
  out
}

# `data` with a numeric `year` or `survey_id` as character (see id_text()).
ids_as_character <- function(data) {
  for (col in intersect(c("year", "survey_id"), names(data))) {
    if (is.numeric(data[[col]])) {
      data[[col]] <- id_text(data[[col]])
    }
  }
  data
}

# `data` with `year` as a factor after `site`, a numeric year taking its
# character level.
with_year <- function(data) {
  data <- ids_as_character(tibble::as_tibble(data))
  data$year <- factor(data$year)
  dplyr::relocate(data, "year", .after = "site")
}
