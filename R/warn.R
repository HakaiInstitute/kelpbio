# Plausibility warnings warn rather than abort, so unusual but valid data are
# never blocked.

# Past the tide limit (positive canopy at a tide height of at least one over
# the slope) the corrected canopy is the cap, not the canopy measured. A row
# warns when that holds on more than 5% of the slope's distribution, the share
# beyond each 95% limit, so the cap reaches into its interval.
warn_tide_cap <- function(share, x_name, rows, cap, basis) {
  n <- sum(share > 0.05)
  if (n > 0L) {
    rows <- if (n == 1L) rows else paste0(rows, "s")
    cli::cli_warn(c(
      "{n} {rows} in {x_name} {cli::qty(n)}{?is/are} past the tide limit ({.field canopy_tide_height_m} at least 1 / {.field tide_height_slope}) {basis}.",
      i = "There the corrected canopy is {cap}, not the canopy measured. Fly at lower tides where possible."
    ))
  }
  invisible(share)
}

# When every empty survey has a percent cover at or below every occupied
# survey's, the presence slope is set by its prior (HakaiInstitute/kelpbio#66).
# The totals are unaffected, since they are evaluated at full cover.
warn_presence_separation <- function(data, x_name) {
  cover <- data$canopy_area_m2 / data$plot_area_m2
  empty <- data$biomass_kg_m2 == 0
  if (any(empty) && max(cover[empty]) <= min(cover[!empty])) {
    cli::cli_warn(c(
      "Every survey in {x_name} with no plants has a percent canopy cover at or below every survey with plants.",
      i = "{.field presence_cover_slope} then follows its prior. Consider a tighter one, such as {.code kb_prior_normal(mean = 0, sd = 5)}."
    ))
  }
  invisible(data)
}

# The share of slope draws on which each row is past the tide limit.
tide_cap_share <- function(canopy_area_m2, canopy_tide_height_m, tide_height_slope) {
  slope <- as.vector(posterior::draws_of(tide_height_slope))
  past <- outer(slope, canopy_tide_height_m) >= 1
  ifelse(canopy_area_m2 > 0, colMeans(past), 0)
}

# The probability that each row is past the tide limit under a Normal prior on
# the slope truncated to its support [0, TIDE_SLOPE_UPPER]. A prior with no
# mass on the support, to numerical precision, is a point mass at the nearer
# bound.
tide_cap_prior_share <- function(canopy_area_m2, canopy_tide_height_m, prior) {
  upper <- TIDE_SLOPE_UPPER
  limit <- pmin(1 / pmax(canopy_tide_height_m, 0), upper)
  mass <- function(x) stats::pnorm(x, prior$mean, prior$sd)
  support <- mass(upper) - mass(0)
  share <- if (support > 0) {
    (mass(upper) - mass(limit)) / support
  } else if (prior$mean > upper) {
    as.numeric(upper * canopy_tide_height_m >= 1)
  } else {
    rep(0, length(canopy_tide_height_m))
  }
  ifelse(canopy_area_m2 > 0, share, 0)
}

# The plausible range of each tissue ratio for kelp; values outside it usually
# mean a unit mistake, a failed analysis, or a transcription error.
# - carbon: 0.10 to 0.50, the stoichiometric range for kelp tissue
#   (Pessarrodona et al. 2023).
# - nitrogen: 0.002 to 0.05, the range of brown-algal tissue nitrogen (Duarte
#   1992; Rosell and Srivastava 1985), the analysis project's exclusion bounds.
# - dry_wet: 0.02 to 0.50, bounds in natural gaps of the Hakai Institute lab
#   data (no ratios between 0.021 and 0.038, or between 0.21 and 0.46).
TISSUE_RATIO_RANGES <- list(
  carbon = c(0.10, 0.50),
  nitrogen = c(0.002, 0.05),
  dry_wet = c(0.02, 0.50)
)

warn_tissue_ratio <- function(data, ratio, x_name) {
  value <- switch(
    ratio,
    carbon = carbon_fraction(data),
    nitrogen = nitrogen_fraction(data),
    dry_wet = data$dry_mass_g / data$wet_mass_g
  )
  range <- TISSUE_RATIO_RANGES[[ratio]]
  n <- sum(value < range[1] | value > range[2])
  if (n > 0L) {
    label <- c(
      carbon = "carbon fraction",
      nitrogen = "nitrogen fraction",
      dry_wet = "dry:wet mass ratio"
    )[[ratio]]
    shown <- vapply(range, format, character(1), nsmall = 2)
    hint <- if (ratio == "dry_wet") {
      "Check the wet and dry masses for transcription or weighing errors."
    } else {
      "Check that {.field {ratio}_mass_ug} is in micrograms and {.field sample_mass_mg} in milligrams."
    }
    # cli::qty(n) restates the count for the verb, since x_name sits between them.
    cli::cli_warn(c(
      "{n} sample{?s} in {x_name} {cli::qty(n)}{?has a/have} {label}{cli::qty(n)}{?s} outside {shown[1]} to {shown[2]}, the plausible range for kelp tissue.",
      i = hint
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
    survey_area_m2 = c(1, 5000),
    plot_area_m2 = c(1, 1e6),
    classified_area_m2 = c(10, 1e9),
    canopy_tide_height_m = c(-1, 5),
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

# Surveying beyond the plot polygon is possible, but swapped area columns are
# the likelier cause.
warn_survey_area <- function(data, x_name) {
  if (!all(c("survey_area_m2", "plot_area_m2") %in% names(data))) {
    return(invisible(data))
  }
  n <- sum(data$survey_area_m2 > data$plot_area_m2, na.rm = TRUE)
  if (n > 0L) {
    cli::cli_warn(c(
      "{n} survey{?s} in {x_name} {cli::qty(n)}{?has/have} {.field survey_area_m2} > {.field plot_area_m2}.",
      i = "Check that the two columns are not swapped."
    ))
  }
  invisible(data)
}

# Two rows for one site-year in a `pool_by` group are two totals over the same
# mapped canopy, so their sum double counts. `id` gives each row's group.
warn_overlapping_canopy <- function(grid, id) {
  key <- site_year_key(grid$site, grid$year)
  repeated <- unique(key[duplicated(paste(id, key))])
  if (length(repeated)) {
    cli::cli_warn(c(
      "Some {.arg pool_by} groups hold more than one row for a site-year, so their totals overlap.",
      i = "Each row is a map of the site-year's bed, so the sum counts it once per map.",
      i = "Repeated: {.val {repeated}}."
    ))
  }
  invisible(NULL)
}

# Warn when values lie below half the fitted minimum or above twice the fitted
# maximum.
warn_outside_range <- function(fit, values, col) {
  fitted <- suppressWarnings(as.numeric(fit$data[[col]]))
  values <- suppressWarnings(as.numeric(values))
  if (all(is.na(fitted)) || all(is.na(values))) {
    return(invisible(NULL))
  }
  lo <- min(fitted, na.rm = TRUE)
  hi <- max(fitted, na.rm = TRUE)
  n <- sum(values < lo / 2 | values > 2 * hi, na.rm = TRUE)
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
