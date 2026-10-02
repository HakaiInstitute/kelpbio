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
