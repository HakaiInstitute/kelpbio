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

# Any site or year column of new_data. A numeric year names a level.
.vld_new_data_groups <- function(x) {
  !anyNA(x[intersect(.group_vars(), names(x))])
}

.vld_frond_count <- function(x) {
  .vld_positive_measure(x) && all(x == round(x))
}

.vld_frond_reaches_1m <- function(x) {
  all(x >= 1)
}

.vld_date <- function(x) {
  inherits(x, "Date") && !anyNA(x)
}

# Run after checking `date`. A survey table need not carry `year`.
.vld_date_year <- function(x) {
  !"year" %in% names(x) || identical(as.character(x$year), date_year(x$date))
}

.vld_unique_surveys <- function(x) {
  !anyDuplicated(survey_key(x$site, x$plot_id, x$date))
}

# The drone pairing of a survey: all three columns given or all missing on each
# row, or the columns absent.
.vld_drone_columns <- function(x) {
  cols <- c("plot_area_m2", "canopy_area_m2", "tide_height_m")
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

.vld_plants_join <- function(plants, survey) {
  all(
    survey_key(plants$site, plants$plot_id, plants$date) %in%
      survey_key(survey$site, survey$plot_id, survey$date)
  )
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
    all(c("canopy_area_m2", "plot_area_m2", "tide_height_m") %in% names(x)) &&
    is.numeric(x$canopy_area_m2) &&
    !anyNA(x$canopy_area_m2) &&
    .vld_finite(x$canopy_area_m2) &&
    all(x$canopy_area_m2 >= 0) &&
    .vld_positive_measure(x$plot_area_m2) &&
    all(x$canopy_area_m2 <= x$plot_area_m2) &&
    is.numeric(x$tide_height_m) &&
    !anyNA(x$tide_height_m) &&
    .vld_finite(x$tide_height_m) &&
    (!"biomass_sd_kg_m2" %in% names(x) || .vld_biomass_sd(x$biomass_sd_kg_m2))
}

.vld_biomass_sd <- function(x) {
  is.numeric(x) && !anyNA(x) && .vld_finite(x) && all(x >= 0)
}

# Drone surveys of sites for site totals; `site_area_m2` is optional.
.vld_site_surveys <- function(x) {
  is.data.frame(x) &&
    all(c("canopy_area_m2", "tide_height_m", "site", "year") %in% names(x)) &&
    is.numeric(x$canopy_area_m2) &&
    !anyNA(x$canopy_area_m2) &&
    .vld_finite(x$canopy_area_m2) &&
    all(x$canopy_area_m2 >= 0) &&
    is.numeric(x$tide_height_m) &&
    !anyNA(x$tide_height_m) &&
    .vld_finite(x$tide_height_m) &&
    .vld_group_column(x$site) &&
    .vld_group_column(x$year) &&
    (!"site_area_m2" %in% names(x) ||
      (.vld_positive_measure(x$site_area_m2) &&
        all(x$canopy_area_m2 <= x$site_area_m2)))
}

.vld_group_column <- function(x) {
  (is.character(x) || is.factor(x)) && !anyNA(x)
}

.vld_census_size <- function(weight, plants) {
  weight$meta$predictor %in% names(plants)
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
