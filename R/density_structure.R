# Density covariate structure: list(has_column, on, levels, mean, sd,
# n_unrecorded), `levels` named by site_year_key(). A row with NA takes its
# site-year's recorded value. Mean and SD are over rows (plant-weighted, as in the
# analysis model). The term needs at least two distinct values.
density_structure <- function(data) {
  out <- list(
    has_column = "stipes_m2" %in% names(data),
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
  density <- as.numeric(data$stipes_m2)
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

# Silent when progress = "none" or the data have no density column.
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
