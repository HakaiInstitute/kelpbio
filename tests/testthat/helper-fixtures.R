# Cached fit fixture, built by fixtures/make-fixtures.R. Downstream method tests
# read this instead of re-sampling. Rebuild after changing the Stan model or the
# kb_fit object structure.
weight_fit <- readRDS(testthat::test_path("fixtures", "weight_fit.rds"))
