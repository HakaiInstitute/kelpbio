# Plausibility warnings warn rather than abort, so unusual but valid data are
# never blocked.

# 0.10 to 0.50 is the stoichiometric range for kelp tissue (Pessarrodona et al.
# 2023); values outside it usually mean a unit mistake or a failed analysis.
warn_carbon_fraction <- function(data, x_name) {
  fraction <- carbon_fraction(data)
  n <- sum(fraction < 0.10 | fraction > 0.50)
  if (n > 0L) {
    # cli::qty(n) restates the count for the verb, since x_name sits between them.
    cli::cli_warn(c(
      "{n} sample{?s} in {x_name} {cli::qty(n)}{?has a/have} carbon fraction{?s} outside 0.10 to 0.50, the plausible range for kelp tissue.",
      i = "Check that {.field carbon_mass_ug} is in micrograms and {.field sample_mass_mg} in milligrams."
    ))
  }
  invisible(data)
}

# The bounds lie in natural gaps of the Hakai Institute lab data (no ratios
# between 0.021 and 0.038, or between 0.21 and 0.46).
warn_dry_wet_ratio <- function(data, x_name) {
  ratio <- data$dry_mass_g / data$wet_mass_g
  n <- sum(ratio < 0.02 | ratio > 0.5)
  if (n > 0L) {
    # cli::qty(n) restates the count for the verb, since x_name sits between them.
    cli::cli_warn(c(
      "{n} sample{?s} in {x_name} {cli::qty(n)}{?has a/have} dry:wet mass ratio{?s} outside 0.02 to 0.5, the plausible range for kelp tissue.",
      i = "Check the wet and dry masses for transcription or weighing errors."
    ))
  }
  invisible(data)
}

# Tools like tidybayes split names such as site_year_effect[<site>,<year>] on
# the comma. A warning, not an error: indexing the draws by name is unaffected.
warn_group_names <- function(data, x_name) {
  for (col in intersect(c("site", "year"), names(data))) {
    values <- unique(as.character(data[[col]]))
    bad <- values[grepl("[],[]", values)]
    if (length(bad)) {
      nm <- column_xname(x_name, col)
      cli::cli_warn(c(
        "{nm} has value{?s} {.val {bad}} containing a comma or square bracket.",
        i = "Parameter names such as {.code site_year_effect[<site>,<year>]} built from such values cannot be split back into their levels by tools that parse them."
      ))
    }
  }
  invisible(data)
}

# The limits lie well beyond the site-year medians in the reference data
# (Nereocystis: the coastwide harvest compilation; otherwise Hakai Institute
# surveys and lab samples) and well inside what a unit mistake produces. The
# median, so a few extreme plants do not trigger it. Tide heights are chart datum.
warn_implausible_units <- function(data, x_name) {
  limits <- list(
    diameter_mm = c(10, 200),
    weight_kg = c(-Inf, 100),
    stipes_m2 = c(-Inf, 100),
    area_m2 = c(1, 5000),
    plot_area_m2 = c(1, 1e6),
    site_area_m2 = c(10, 1e9),
    tide_height_m = c(-1, 5),
    wet_mass_g = c(-Inf, 1000),
    dry_mass_g = c(-Inf, 1000)
  )
  for (col in intersect(names(limits), names(data))) {
    x <- suppressWarnings(as.numeric(data[[col]]))
    if (all(is.na(x))) {
      next
    }
    m <- stats::median(x, na.rm = TRUE)
    lim <- limits[[col]]
    if (m < lim[1] || m > lim[2]) {
      nm <- column_xname(x_name, col)
      unit <- column_units[[col]]
      shown <- signif(m, 3)
      size <- if (m < lim[1]) "small" else "large"
      cli::cli_warn(c(
        "{nm} has median {shown}, which is unusually {size} for {unit}.",
        i = "Check that {.field {col}} is in {unit}."
      ))
    }
  }
  invisible(data)
}

# Warn when values lie below half the fitted minimum or above twice the fitted
# maximum. `lower = FALSE` is for a column whose unit mistakes only inflate
# values (density) and whose small values are real sparse sites.
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
