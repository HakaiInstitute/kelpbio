# Warn when a column's median is implausible in its expected unit. The limits lie
# well beyond the site-year medians in the reference data (Nereocystis: the
# coastwide harvest compilation, Alaska to California; Macrocystis weight, stipe
# density, transect area, sample masses, drone plots, and tide heights:
# Hakai Institute surveys and lab samples) and well inside what a unit mistake
# (centimetres, grams, stipes per hectare, square centimetres or hectares,
# milligrams) produces. Tide heights are chart datum, so can be negative. The median, so
# a few extreme plants do not trigger it; a warning, so valid but unusual data
# are never blocked.
warn_implausible_units <- function(data, x_name) {
  limits <- list(
    diameter_mm = c(10, 200),
    weight_kg = c(-Inf, 100),
    stipes_m2 = c(-Inf, 100),
    area_m2 = c(1, 5000),
    plot_area_m2 = c(1, 1e6),
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
      nm <- kb_xname(x_name, col)
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
