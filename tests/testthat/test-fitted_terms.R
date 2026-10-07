test_that(".fitted_draws keeps only the estimated effects", {
  off <- weight_nereo_fit
  off$meta$terms$fixed <- setdiff(off$meta$terms$fixed, "density_slope")
  vars <- posterior::variables(.fitted_draws(off))
  expect_false("density_slope" %in% vars)
  expect_setequal(vars, c(off$meta$terms$fixed, off$meta$terms$random))
  expect_true("density_slope" %in% posterior::variables(off$draws))
})

test_that(".fitted_diagnostics keeps rows of estimated effects, indexed or not", {
  off <- weight_nereo_fit
  off$meta$terms$random <- setdiff(off$meta$terms$random, "site_year_effect")
  vars <- .fitted_diagnostics(off)$variable
  expect_false(any(grepl("^site_year_effect\\[", vars)))
  expect_true(any(grepl("^site_effect\\[", vars)))
  expect_true("intercept" %in% vars)
})
