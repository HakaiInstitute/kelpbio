# The grouping factors every kelpbio model shares. kelpbio works at site-year
# resolution and implements no month effect, so site and year are the only two
# and the set is exhaustive rather than a default: the models that group at all
# (weight, size, density, blade fraction) group by these, and the intercept-only
# ones (wet/dry, carbon, nitrogen, harvestable) have no random effects, leaving
# meta$site_levels / meta$year_levels empty so the level checks pass trivially.
# Read through here so the guard, the index resolution and the prediction
# metadata cannot fall out of step.
.group_vars <- function() {
  c("site", "year")
}

# The fitted levels of one grouping factor, empty for a model that does not use it.
.fit_levels <- function(fit, nm) {
  fit$meta[[paste0(nm, "_levels")]]
}
