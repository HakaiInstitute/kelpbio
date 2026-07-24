# Cached fit fixtures, built by fixtures/make-fixtures.R. Downstream method tests
# read these instead of re-sampling. Rebuild after changing a Stan model or the
# kb_fit object structure. Reads are guarded with file.exists() so that
# devtools::load_all() (which sources test helpers) still succeeds while the
# fixtures are being (re)built by a script that itself calls load_all().
fixture <- function(name) {
  path <- testthat::test_path("fixtures", name)
  if (file.exists(path)) readRDS(path) else NULL
}

# Nereocystis (Student-t) and Macrocystis (Gamma) weight fits. Fit/check tests
# use the bundled simulated datasets (data_weight_sim_*) directly, so there are
# no separate simulated-data fixtures.
weight_fit <- fixture("weight_fit.rds")
weight_macro_fit <- fixture("weight_macro_fit.rds")
