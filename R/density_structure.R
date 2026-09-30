# Determine the density covariate structure from the data and notify the user.
# Density is a site-year value, so a row with NA takes the value recorded for its
# site-year in another row (kb_check_data_weight_nereo() has already rejected
# conflicting values within a site-year).
#
# Pure: returns list(has_column, on, levels, mean, sd, n_unrecorded). `levels` is
# the recorded density of each site-year, named by site_year_key(). The mean and
# SD are over rows, not site-years, so the standardisation matches the analysis
# model's (plant-weighted). The term needs at least two distinct values, since a
# single value has no spread to estimate an effect from.
density_structure <- function(data) {
  out <- list(
    has_column = "density" %in% names(data),
    on = FALSE,
    levels = stats::setNames(numeric(0), character(0)),
    mean = NA_real_,
    sd = NA_real_,
    n_unrecorded = 0L
  )
  if (!out$has_column || !nrow(data)) {
    return(out)
  }

  key <- site_year_key(data$site, data$year)
  density <- as.numeric(data$density)
  recorded <- !is.na(density)
  first <- !duplicated(key[recorded])
  levels <- stats::setNames(density[recorded][first], key[recorded][first])
  row_density <- unname(levels[key])

  out$levels <- levels
  out$n_unrecorded <- sum(!unique(key) %in% names(levels))
  out$on <- length(unique(levels)) > 1L
  if (out$on) {
    out$mean <- mean(row_density, na.rm = TRUE)
    out$sd <- stats::sd(row_density, na.rm = TRUE)
  }
  out
}

# Emit the density notices. Informational, so suppressed when progress = "none";
# silent when the data have no density column, since fitting without density is
# the ordinary case.
notify_density <- function(status, progress = "bar") {
  if (identical(progress, "none") || !status$has_column) {
    return(invisible(status))
  }
  if (!status$on) {
    cli::cli_inform(c(
      i = "The density effect is omitted: fewer than two distinct site-year densities are recorded."
    ))
  } else if (status$n_unrecorded > 0L) {
    n <- status$n_unrecorded
    cli::cli_inform(c(
      i = "Density is not recorded for {n} site-year{?s}; {?it takes/they take} the mean density."
    ))
  }
  invisible(status)
}
