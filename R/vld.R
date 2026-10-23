.vld_kb_fit <- function(x, class = "kb_fit") {
  inherits(x, class)
}

# The models with grouping factors, which kb_new_data() builds grids for.
.vld_kb_fit_grouped <- function(x) {
  inherits(
    x,
    c("kb_fit_weight", "kb_fit_size", "kb_fit_cover_calibration")
  )
}

.vld_same_species <- function(fits) {
  length(unique(vapply(fits, function(f) f$meta$species, character(1)))) == 1L
}

.vld_same_ndraws <- function(fits) {
  length(unique(vapply(fits, function(f) posterior::ndraws(f$draws), numeric(1)))) == 1L
}

.vld_representative_site <- function(representative_site, site_levels) {
  is.null(representative_site) ||
    (is.character(representative_site) &&
      length(representative_site) > 0L &&
      all(representative_site %in% site_levels))
}

# The shape of representative_site in a verb taking several fits with site
# effects: a character vector for every fit, or a list naming the fits in
# `fits`. Each fit's sites are checked by .vld_representative_site().
.vld_representative_site_fits <- function(representative_site, fits) {
  if (!is.list(representative_site)) {
    return(TRUE)
  }
  nms <- names(representative_site)
  !is.null(nms) &&
    all(nms %in% fits) &&
    !anyDuplicated(nms) &&
    all(vapply(representative_site, function(x) is.null(x) || is.character(x), logical(1)))
}

.vld_new_data_weight_nereo <- function(x) {
  is.data.frame(x) &&
    "diameter_mm" %in% names(x) &&
    .vld_positive_measure(x$diameter_mm)
}

.vld_positive_measure <- function(x) {
  is.numeric(x) && !anyNA(x) && .vld_finite(x) && all(x > 0)
}

.vld_finite <- function(x) {
  !any(is.infinite(x))
}

.vld_rows <- function(x) {
  nrow(x) > 0L
}

# Any site or year column of new_data; a year may be whole numbers.
.vld_new_data_groups <- function(x) {
  groups <- intersect(.group_vars(), names(x))
  !anyNA(x[groups]) && (!"year" %in% groups || .vld_id_column(x$year, "year"))
}

.vld_frond_count <- function(x) {
  .vld_positive_measure(x) && all(x == round(x))
}

.vld_frond_reaches_1m <- function(x) {
  all(x >= 1)
}

.vld_unique_surveys <- function(x) {
  !anyDuplicated(id_text(x$survey_id))
}

# The drone pairing of a survey: all three columns given or all missing on each
# row, or the columns absent.
.vld_drone_columns <- function(x) {
  cols <- c("plot_area_m2", "canopy_area_m2", "canopy_tide_height_m")
  present <- intersect(cols, names(x))
  if (!length(present)) {
    return(TRUE)
  }
  if (length(present) < length(cols)) {
    return(FALSE)
  }
  missing <- is.na(x[cols])
  if (!all(rowSums(missing) %in% c(0L, length(cols)))) {
    return(FALSE)
  }
  paired <- !missing[, 1L]
  d <- x[paired, cols, drop = FALSE]
  all(vapply(d, is.numeric, logical(1))) &&
    all(vapply(d, .vld_finite, logical(1))) &&
    all(d$plot_area_m2 > 0) &&
    all(d$canopy_area_m2 >= 0) &&
    all(d$canopy_area_m2 <= d$plot_area_m2)
}

.vld_partial <- function(x) {
  is.logical(x) && !anyNA(x)
}

.vld_census_join <- function(size_census, survey) {
  all(id_text(size_census$survey_id) %in% id_text(survey$survey_id))
}

.vld_new_data_weight_macro <- function(x) {
  is.data.frame(x) && "fronds" %in% names(x) && .vld_frond_count(x$fronds)
}

# Size new_data has no predictor column.
.vld_new_data_size <- function(x) {
  is.data.frame(x)
}

.vld_progress <- function(x) {
  is.character(x) &&
    length(x) == 1L &&
    !is.na(x) &&
    x %in% c("bar", "verbose", "none")
}

# Unnamed arguments would bind to sampling()'s first free formal, `pars`.
.vld_sampling_dots <- function(x) {
  all(rlang::names2(x) != "") &&
    !any(rlang::names2(x) %in% names(SAMPLING_RESERVED))
}

.vld_progress_dir <- function(x) {
  is.null(x) ||
    (is.character(x) &&
      length(x) == 1L &&
      !is.na(x) &&
      dir.exists(x) &&
      file.access(x, mode = 2L) == 0L)
}

# Zero-row data sample the priors alone, which only prior_only asks for.
.vld_fit_rows <- function(data, prior_only) {
  prior_only || nrow(data) > 0L
}

.vld_observed_data <- function(fit) {
  nrow(fit$data) > 0L
}

.vld_sensitivity_fit <- function(fit) {
  !isTRUE(fit$meta$prior_only) && .vld_observed_data(fit)
}

.vld_loo_fit <- function(fit) {
  !isTRUE(fit$meta$prior_only) && .vld_observed_data(fit)
}

# The survey columns of cover calibration data and new_data.
.vld_cover_survey <- function(x) {
  is.data.frame(x) &&
    all(c("canopy_area_m2", "plot_area_m2", "canopy_tide_height_m") %in% names(x)) &&
    is.numeric(x$canopy_area_m2) &&
    !anyNA(x$canopy_area_m2) &&
    .vld_finite(x$canopy_area_m2) &&
    all(x$canopy_area_m2 >= 0) &&
    .vld_positive_measure(x$plot_area_m2) &&
    all(x$canopy_area_m2 <= x$plot_area_m2) &&
    is.numeric(x$canopy_tide_height_m) &&
    !anyNA(x$canopy_tide_height_m) &&
    .vld_finite(x$canopy_tide_height_m) &&
    (!"biomass_sd_kg_m2" %in% names(x) || .vld_biomass_sd(x$biomass_sd_kg_m2))
}

.vld_biomass_sd <- function(x) {
  is.numeric(x) && !anyNA(x) && .vld_finite(x) && all(x >= 0)
}

# Mapped canopy for canopy totals.
.vld_canopy_maps <- function(x) {
  is.data.frame(x) &&
    all(c("canopy_area_m2", "canopy_tide_height_m", "site", "year", "classified_area_m2") %in% names(x)) &&
    is.numeric(x$canopy_area_m2) &&
    !anyNA(x$canopy_area_m2) &&
    .vld_finite(x$canopy_area_m2) &&
    all(x$canopy_area_m2 >= 0) &&
    is.numeric(x$canopy_tide_height_m) &&
    !anyNA(x$canopy_tide_height_m) &&
    .vld_finite(x$canopy_tide_height_m) &&
    .vld_group_column(x$site) &&
    .vld_id_column(x$year, "year") &&
    .vld_positive_measure(x$classified_area_m2) &&
    all(x$canopy_area_m2 <= x$classified_area_m2)
}

.vld_group_column <- function(x) {
  (is.character(x) || is.factor(x)) && !anyNA(x)
}

# A grouping or identifier column named `col`: `year` may also be whole numbers,
# and `survey_id` any finite numbers.
.vld_id_column <- function(x, col) {
  if (is.numeric(x) && col %in% c("year", "survey_id")) {
    return(.vld_finite(x) && !anyNA(x) && (col != "year" || all(x == round(x))))
  }
  .vld_group_column(x)
}

.vld_census_size <- function(weight, size_census) {
  weight$meta$predictor %in% names(size_census)
}

.vld_measure_fits <- function(measure, wetdry, carbon) {
  (!measure %in% c("dry", "carbon") || !is.null(wetdry)) &&
    (measure != "carbon" || !is.null(carbon)) &&
    (is.null(wetdry) || .vld_kb_fit(wetdry, "kb_fit_wetdry")) &&
    (is.null(carbon) || .vld_kb_fit(carbon, "kb_fit_carbon"))
}

.vld_pool_by <- function(pool_by, data) {
  is.null(pool_by) ||
    (is.character(pool_by) &&
      !anyNA(pool_by) &&
      all(pool_by %in% names(data)) &&
      all(vapply(data[pool_by], .vld_group_column, logical(1))))
}

.vld_predictions <- function(x) {
  is.data.frame(x) && all(c("estimate", "lower", "upper") %in% names(x))
}

.vld_plot_x <- function(x, predictions) {
  !is.null(x) && x %in% names(predictions)
}

.vld_log_y <- function(predictions) {
  !any(
    c(predictions$estimate, predictions$lower, predictions$upper) <= 0,
    na.rm = TRUE
  )
}

.vld_log_x <- function(predictions, x) {
  is.numeric(predictions[[x]]) && !any(predictions[[x]] <= 0, na.rm = TRUE)
}

.vld_log_axis <- function(log_axis, predictions, x) {
  (log_axis == "none" || .vld_log_y(predictions)) &&
    (log_axis != "xy" || .vld_log_x(predictions, x))
}
