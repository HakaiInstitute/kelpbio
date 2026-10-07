# Validity predicates (logical scalars, no messaging); paired with .chk_ in chk.R.

.vld_kb_fit <- function(x) {
  inherits(x, "kb_fit")
}

.vld_kb_fit_weight <- function(x) {
  inherits(x, "kb_fit_weight")
}

.vld_kb_fit_size <- function(x) {
  inherits(x, "kb_fit_size")
}

.vld_kb_fit_density <- function(x) {
  inherits(x, "kb_fit_density")
}

# The models with grouping factors, which kb_new_data() builds grids for.
.vld_kb_fit_grouped <- function(x) {
  inherits(
    x,
    c("kb_fit_weight", "kb_fit_size", "kb_fit_density", "kb_fit_cover_biomass")
  )
}

.vld_kb_fit_wetdry <- function(x) {
  inherits(x, "kb_fit_wetdry")
}

.vld_kb_fit_carbon <- function(x) {
  inherits(x, "kb_fit_carbon")
}

# A list of fits shares one species.
.vld_same_species <- function(fits) {
  length(unique(vapply(fits, function(f) f$meta$species, character(1)))) == 1L
}

# A list of fits shares one number of posterior draws.
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

# A measured size: numeric, positive, no missing values.
.vld_positive_measure <- function(x) {
  is.numeric(x) && !anyNA(x) && all(x > 0)
}

# A frond count: a positive whole number with no missing values.
.vld_frond_count <- function(x) {
  .vld_positive_measure(x) && all(x == round(x))
}

# Stipe density: numeric (or all NA) and non-negative where recorded.
.vld_density <- function(x) {
  all(is.na(x)) || (is.numeric(x) && all(x >= 0, na.rm = TRUE))
}

# Density is a site-year value: at most one distinct recorded value per site-year.
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

# Size new_data has no predictor: any data frame, with optional site and year.
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

.vld_progress_dir <- function(x) {
  is.null(x) ||
    (is.character(x) && length(x) == 1L && !is.na(x) && dir.exists(x))
}

.vld_observed_data <- function(fit) {
  nrow(fit$data) > 0L
}

# A fit whose sensitivity to its prior and likelihood can be assessed: fitted to
# data (not prior-only), with at least one observation.
.vld_sensitivity_fit <- function(fit) {
  !isTRUE(fit$meta$prior_only) && .vld_observed_data(fit)
}

.vld_kb_fit_cover_biomass <- function(x) {
  inherits(x, "kb_fit_cover_biomass")
}

# The survey columns of cover biomass data and new_data: a canopy area within a positive
# plot area, and the tide height, all numeric with no missing values.
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

# Compatibility limits of an in situ biomass estimate: positive, with no missing
# values, and the lower strictly below the upper so the implied SD is positive.
.vld_biomass_limits <- function(x) {
  is.data.frame(x) &&
    all(c("lower", "upper") %in% names(x)) &&
    .vld_positive_measure(x$lower) &&
    .vld_positive_measure(x$upper) &&
    all(x$lower < x$upper)
}

# The in situ biomass of a cover biomass fit: one row per site-year, each a valid
# estimate within its limits.
.vld_plot_biomass <- function(x) {
  is.data.frame(x) &&
    all(c("site", "year") %in% names(x)) &&
    (is.character(x$site) || is.factor(x$site)) &&
    (is.character(x$year) || is.factor(x$year)) &&
    !anyNA(x$site) &&
    !anyNA(x$year) &&
    .vld_biomass_estimate(x) &&
    !anyDuplicated(site_year_key(x$site, x$year))
}

# An in situ biomass estimate: positive, and within its limits.
.vld_biomass_estimate <- function(x) {
  .vld_biomass_limits(x) &&
    "estimate" %in% names(x) &&
    .vld_positive_measure(x$estimate) &&
    all(x$lower <= x$estimate & x$estimate <= x$upper)
}


# Drone surveys of sites for site totals: a non-negative canopy area and a tide
# height, site and year labels, all with no missing values, and an optional site
# area at least as large as the canopy.
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

# A grouping column: character or factor with no missing values.
.vld_group_column <- function(x) {
  (is.character(x) || is.factor(x)) && !anyNA(x)
}

# `sum_by`: NULL, or names of grouping columns of `data`.
.vld_sum_by <- function(sum_by, data) {
  is.null(sum_by) ||
    (is.character(sum_by) &&
      !anyNA(sum_by) &&
      all(sum_by %in% names(data)) &&
      all(vapply(data[sum_by], .vld_group_column, logical(1))))
}
