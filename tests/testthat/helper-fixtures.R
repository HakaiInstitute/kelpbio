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

# Keep only `variables` of a fit's stored draws and diagnostics, as fit_stan()
# stores only the parameters a fit estimates.
keep_parameters <- function(fit, variables) {
  fit$draws <- posterior::subset_draws(fit$draws, variable = variables)
  s <- fit$diagnostics$summary
  fit$diagnostics$summary <- s[sub("\\[.*$", "", s$variable) %in% variables, ]
  fit
}

# A fit as it would be built with `terms` switched off.
omit_terms <- function(fit, terms) {
  fit$meta$terms <- lapply(fit$meta$terms, setdiff, terms)
  if ("density_slope" %in% terms) fit$meta$density_on <- FALSE
  if ("site_year_effect" %in% terms) fit$meta$site_year_on <- FALSE
  keep_parameters(fit, unlist(fit$meta$terms, use.names = FALSE))
}

# Stand in for fit_stan(): return `fit`'s draws for the parameters requested,
# so a fit function can be tested without sampling.
local_fit_stan_stub <- function(fit, env = parent.frame()) {
  testthat::local_mocked_bindings(
    fit_stan = function(stanmodel, stan_data, param_vars, ...) {
      core <- keep_parameters(fit, param_vars)
      list(draws = core$draws, diagnostics = core$diagnostics, stancode = "")
    },
    .env = env
  )
}
