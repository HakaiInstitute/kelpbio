# Cached fit fixtures, built by fixtures/make-fixtures.R. Downstream method tests
# read these instead of re-sampling. Rebuild after changing a Stan model or the
# kb_fit object structure. Reads are guarded with file.exists() so that
# devtools::load_all() (which sources test helpers) still succeeds while the
# fixtures are being (re)built by a script that itself calls load_all().
fixture <- function(name) {
  path <- testthat::test_path("fixtures", name)
  if (file.exists(path)) readRDS(path) else NULL
}

# Nereocystis (lognormal) and Macrocystis (Gamma) weight fits, the Nereocystis
# (Weibull) and Macrocystis (zero-truncated negative binomial) size fits, and the
# Nereocystis (zero-inflated negative binomial) and Macrocystis (negative
# binomial) density fits, and the Beta wet/dry and carbon fits. Fit/check tests use the bundled simulated datasets
# (data_*_sim_*) directly, so there are no separate simulated-data fixtures.
weight_fit <- fixture("weight_fit.rds")
weight_macro_fit <- fixture("weight_macro_fit.rds")
size_nereo_fit <- fixture("size_nereo_fit.rds")
size_macro_fit <- fixture("size_macro_fit.rds")
density_nereo_fit <- fixture("density_nereo_fit.rds")
density_macro_fit <- fixture("density_macro_fit.rds")
wetdry_nereo_fit <- fixture("wetdry_nereo_fit.rds")
wetdry_macro_fit <- fixture("wetdry_macro_fit.rds")
carbon_nereo_fit <- fixture("carbon_nereo_fit.rds")
carbon_macro_fit <- fixture("carbon_macro_fit.rds")
