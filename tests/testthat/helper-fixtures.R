# NULL when absent, so load_all() works while make-fixtures.R rebuilds them.
fixture <- function(name) {
  path <- testthat::test_path("fixtures", name)
  if (file.exists(path)) readRDS(path) else NULL
}

weight_nereo_fit <- fixture("weight_nereo_fit.rds")
weight_macro_fit <- fixture("weight_macro_fit.rds")
size_nereo_fit <- fixture("size_nereo_fit.rds")
size_macro_fit <- fixture("size_macro_fit.rds")
density_nereo_fit <- fixture("density_nereo_fit.rds")
density_macro_fit <- fixture("density_macro_fit.rds")
wetdry_nereo_fit <- fixture("wetdry_nereo_fit.rds")
wetdry_macro_fit <- fixture("wetdry_macro_fit.rds")
carbon_nereo_fit <- fixture("carbon_nereo_fit.rds")
carbon_macro_fit <- fixture("carbon_macro_fit.rds")
cover_biomass_nereo_fit <- fixture("cover_biomass_nereo_fit.rds")
cover_biomass_macro_fit <- fixture("cover_biomass_macro_fit.rds")

# The two species' simulated datasets have different site names.
fitted_sites <- function(fit, n = 1) {
  fit$meta$site_levels[seq_len(n)]
}

# Split a cover biomass fit's stored data back into its two inputs.
cover_surveys <- function(fit) {
  fit$data[setdiff(names(fit$data), c("estimate", "lower", "upper"))]
}
cover_biomass <- function(fit) {
  fit$data[c("site", "year", "estimate", "lower", "upper")]
}
