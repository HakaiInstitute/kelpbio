# Cached fit fixture, built by fixtures/make-fixtures.R. Downstream method tests
# read this instead of re-sampling. Rebuild after changing the Stan model or the
# kb_fit object structure.
weight_fit <- readRDS(testthat::test_path("fixtures", "weight_fit.rds"))

# Small simulated dataset (fixtures/make-sim-data.R) for the fit/check tests, so
# they stay fast and independent of the bundled datasets.
sim_weight <- readRDS(testthat::test_path("fixtures", "sim_weight.rds"))
