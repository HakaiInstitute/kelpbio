.vld_kb_fit <- function(x, class = "kb_fit") {
  inherits(x, class)
}

# The models with grouping factors, which kb_new_data() builds grids for.
.vld_kb_fit_grouped <- function(x) {
  inherits(
    x,
    c("kb_fit_weight", "kb_fit_size", "kb_fit_density", "kb_fit_cover_biomass")
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
    .vld_positive_measure(x$diameter_mm) &&
    (!"stipes_m2" %in% names(x) || .vld_density(x$stipes_m2))
}

.vld_positive_measure <- function(x) {
  is.numeric(x) && !anyNA(x) && all(x > 0)
}

.vld_frond_count <- function(x) {
  .vld_positive_measure(x) && all(x == round(x))
}

.vld_frond_reaches_1m <- function(x) {
  all(x >= 1)
}

.vld_density <- function(x) {
  all(is.na(x)) || (is.numeric(x) && all(x >= 0, na.rm = TRUE))
}

.vld_density_site_year <- function(data) {
  recorded <- !is.na(data$stipes_m2)
  key <- site_year_key(data$site, data$year)[recorded]
  n_distinct <- tapply(data$stipes_m2[recorded], key, function(x) {
    length(unique(x))
  })
  all(n_distinct <= 1L)
}

.vld_new_data_weight_macro <- function(x) {
  is.data.frame(x) && "fronds" %in% names(x) && .vld_frond_count(x$fronds)
}

# Size new_data has no predictor column.
.vld_new_data_size <- function(x) {
  is.data.frame(x)
}

# Density new_data may carry the transect area, read by the draw generics.
.vld_new_data_density <- function(x) {
  is.data.frame(x) &&
    (!"area_m2" %in% names(x) || .vld_positive_measure(x$area_m2))
}

.vld_progress <- function(x) {
  is.character(x) &&
    length(x) == 1L &&
    !is.na(x) &&
    x %in% c("bar", "verbose", "none")
}

.vld_sampling_dots <- function(x) {
  !any(rlang::names2(x) %in% names(SAMPLING_RESERVED))
}

.vld_progress_dir <- function(x) {
  is.null(x) ||
    (is.character(x) && length(x) == 1L && !is.na(x) && dir.exists(x))
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

# The survey columns of cover biomass data and new_data.
.vld_cover_survey <- function(x) {
  is.data.frame(x) &&
    all(c("canopy_area_m2", "plot_area_m2", "tide_height_m") %in% names(x)) &&
    is.numeric(x$canopy_area_m2) &&
    !anyNA(x$canopy_area_m2) &&
    all(x$canopy_area_m2 >= 0) &&
    .vld_positive_measure(x$plot_area_m2) &&
    all(x$canopy_area_m2 <= x$plot_area_m2) &&
    is.numeric(x$tide_height_m) &&
    !anyNA(x$tide_height_m)
}

# lower strictly below upper, so the implied log-scale SD is positive.
.vld_biomass_limits <- function(x) {
  is.data.frame(x) &&
    all(c("lower", "upper") %in% names(x)) &&
    .vld_positive_measure(x$lower) &&
    .vld_positive_measure(x$upper) &&
    all(x$lower < x$upper)
}

.vld_plot_biomass <- function(x) {
  is.data.frame(x) &&
    all(c("site", "year") %in% names(x)) &&
    (is.character(x$site) || is.factor(x$site)) &&
    (is.character(x$year) || is.factor(x$year)) &&
    !anyNA(x$site) &&
    !anyNA(x$year) &&
    .vld_biomass_estimate(x) &&
    .vld_biomass_response(x) &&
    !anyDuplicated(site_year_key(x$site, x$year))
}

# A kb_predictions object records its response; the cover fit takes wet biomass.
.vld_biomass_response <- function(x) {
  response <- attr(x, "kb_response", exact = TRUE)
  is.null(response) || identical(response, "biomass_kg_m2")
}

.vld_biomass_estimate <- function(x) {
  .vld_biomass_limits(x) &&
    "estimate" %in% names(x) &&
    .vld_positive_measure(x$estimate) &&
    all(x$lower <= x$estimate & x$estimate <= x$upper)
}


# Drone surveys of sites for site totals; `site_area_m2` is optional.
.vld_site_surveys <- function(x) {
  is.data.frame(x) &&
    all(c("canopy_area_m2", "tide_height_m", "site", "year") %in% names(x)) &&
    is.numeric(x$canopy_area_m2) &&
    !anyNA(x$canopy_area_m2) &&
    all(x$canopy_area_m2 >= 0) &&
    is.numeric(x$tide_height_m) &&
    !anyNA(x$tide_height_m) &&
    .vld_group_column(x$site) &&
    .vld_group_column(x$year) &&
    (!"site_area_m2" %in% names(x) ||
      (.vld_positive_measure(x$site_area_m2) &&
        all(x$canopy_area_m2 <= x$site_area_m2)))
}

.vld_group_column <- function(x) {
  (is.character(x) || is.factor(x)) && !anyNA(x)
}

.vld_sum_by <- function(sum_by, data) {
  is.null(sum_by) ||
    (is.character(sum_by) &&
      !anyNA(sum_by) &&
      all(sum_by %in% names(data)) &&
      all(vapply(data[sum_by], .vld_group_column, logical(1))))
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
