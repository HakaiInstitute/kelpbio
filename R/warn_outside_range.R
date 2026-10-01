# Warn when supplied values lie below half the fitted minimum or above twice the
# fitted maximum, which usually means a unit mistake. `lower = FALSE` checks only
# the upper side, for a column whose unit mistakes only inflate values (density
# per hectare or per 10 m2) and whose small values are real sparse sites. Compared against the
# fitted data rather than a fixed limit, since one small plant in new data is
# valid. Nothing to compare against for a fit with no observations.
warn_outside_range <- function(fit, values, col, lower = TRUE) {
  fitted <- suppressWarnings(as.numeric(fit$data[[col]]))
  values <- suppressWarnings(as.numeric(values))
  if (all(is.na(fitted)) || all(is.na(values))) {
    return(invisible(NULL))
  }
  lo <- min(fitted, na.rm = TRUE)
  hi <- max(fitted, na.rm = TRUE)
  low <- if (lower) values < lo / 2 else FALSE
  n <- sum(low | values > 2 * hi, na.rm = TRUE)
  if (n > 0) {
    unit <- if (col %in% names(column_units)) column_units[[col]] else NULL
    range_txt <- paste(signif(lo, 3), "to", signif(hi, 3))
    msg <- c(
      "{n} value{?s} of {.field {col}} {cli::qty(n)}lie{?s/} far outside the fitted range ({range_txt})."
    )
    if (!is.null(unit)) {
      msg <- c(msg, i = "Check that the values are in {unit}.")
    }
    cli::cli_warn(msg)
  }
  invisible(NULL)
}
