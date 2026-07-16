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
  is.null(x) || (is.data.frame(x) && "diameter" %in% names(x))
}
