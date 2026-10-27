# NULL when absent, so load_all() works while make-fixtures.R rebuilds them.
fixture <- function(name) {
  path <- testthat::test_path("fixtures", name)
  if (file.exists(path)) readRDS(path) else NULL
}

weight_nereo_fit <- fixture("weight_nereo_fit.rds")
weight_macro_fit <- fixture("weight_macro_fit.rds")
size_nereo_fit <- fixture("size_nereo_fit.rds")
wetdry_nereo_fit <- fixture("wetdry_nereo_fit.rds")
wetdry_macro_fit <- fixture("wetdry_macro_fit.rds")
carbon_nereo_fit <- fixture("carbon_nereo_fit.rds")
carbon_macro_fit <- fixture("carbon_macro_fit.rds")
nitrogen_nereo_fit <- fixture("nitrogen_nereo_fit.rds")
nitrogen_macro_fit <- fixture("nitrogen_macro_fit.rds")
cover_calibration_nereo_fit <- fixture("cover_calibration_nereo_fit.rds")
cover_calibration_macro_fit <- fixture("cover_calibration_macro_fit.rds")

# The two species' simulated datasets have different site names.
fitted_sites <- function(fit, n = 1) {
  fit$meta$site_levels[seq_len(n)]
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
  if ("weight_floor" %in% terms) fit$meta$form <- "power"
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

# Survey biomass rows as kb_predict_biomass_in_situ() returns them: drone columns
# and a column of draws with the given means and SDs (an SD of 0 gives a fixed
# value, such as an empty survey's 0).
survey_biomass <- function(
  mean = c(2.8, 0, 6),
  sd = c(0.4, 0, 0.8),
  site = c("a", "b", "a"),
  year = c("2020", "2020", "2021"),
  ndraws = 100L
) {
  # Half the draws at each of mean -/+ a step, so each column's mean and SD are
  # exactly `mean` and `sd`, and no draw is negative while sd < mean.
  z <- rep(c(-1, 1), length.out = ndraws) * sqrt((ndraws - 1) / ndraws)
  draws <- vapply(seq_along(mean), function(i) mean[i] + sd[i] * z, numeric(ndraws))
  tibble::tibble(
    site = site,
    year = year,
    plot_area_m2 = 200,
    canopy_area_m2 = c(60, 0, 120)[seq_along(mean)],
    canopy_tide_height_m = c(0.5, -0.2, 1)[seq_along(mean)],
    biomass_kg_m2 = posterior::rvar(draws)
  )
}

# A calibration fit's stored surveys with their biomass back as draws, the
# input the fit was made from up to the draws' shape.
calibration_input <- function(fit, ndraws = 100L) {
  d <- fit$data
  out <- survey_biomass(
    mean = d$biomass_kg_m2,
    sd = d$biomass_sd_kg_m2,
    # Kept as stored, so the factor codes match the fit's levels.
    site = d$site,
    year = d$year,
    ndraws = ndraws
  )
  out[c("plot_area_m2", "canopy_area_m2", "canopy_tide_height_m")] <-
    d[c("plot_area_m2", "canopy_area_m2", "canopy_tide_height_m")]
  out
}

# Every fixture fit, named for its model and species.
fixture_fits <- list(
  weight_nereo = weight_nereo_fit,
  weight_macro = weight_macro_fit,
  size_nereo = size_nereo_fit,
  wetdry_nereo = wetdry_nereo_fit,
  wetdry_macro = wetdry_macro_fit,
  carbon_nereo = carbon_nereo_fit,
  carbon_macro = carbon_macro_fit,
  nitrogen_nereo = nitrogen_nereo_fit,
  nitrogen_macro = nitrogen_macro_fit,
  cover_calibration_nereo = cover_calibration_nereo_fit,
  cover_calibration_macro = cover_calibration_macro_fit
)
