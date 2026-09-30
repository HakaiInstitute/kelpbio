# Validity predicates (logical scalars, no messaging); paired with .chk_ in chk.R.

.vld_kb_fit <- function(x) {
  inherits(x, "kb_fit")
}

.vld_kb_fit_weight <- function(x) {
  inherits(x, "kb_fit_weight")
}

.vld_representative_site <- function(representative_site, site_levels) {
  is.null(representative_site) ||
    (is.character(representative_site) &&
      length(representative_site) > 0L &&
      all(representative_site %in% site_levels))
}

.vld_new_data_weight_nereo <- function(x) {
  is.data.frame(x) &&
    "diameter" %in% names(x) &&
    (!"density" %in% names(x) || .vld_density(x$density))
}

# Stipe density: numeric (or all NA) and non-negative where recorded.
.vld_density <- function(x) {
  all(is.na(x)) || (is.numeric(x) && all(x >= 0, na.rm = TRUE))
}

# Density is a site-year value: at most one distinct recorded value per site-year.
.vld_density_site_year <- function(data) {
  recorded <- !is.na(data$density)
  key <- site_year_key(data$site, data$year)[recorded]
  n_distinct <- tapply(data$density[recorded], key, function(x) {
    length(unique(x))
  })
  all(n_distinct <= 1L)
}

.vld_new_data_weight_macro <- function(x) {
  is.data.frame(x) && "fronds" %in% names(x)
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
