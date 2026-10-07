# The exhaustive set of grouping factors (no month effect). Intercept-only
# models have empty level sets, so their level checks pass trivially.
.group_vars <- function() {
  c("site", "year")
}

.fit_levels <- function(fit, nm) {
  fit$meta[[paste0(nm, "_levels")]]
}
