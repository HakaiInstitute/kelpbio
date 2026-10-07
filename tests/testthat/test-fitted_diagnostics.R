test_that(".fitted_diagnostics keeps rows of estimated effects, indexed or not", {
  off <- weight_fit
  off$meta$terms$random <- setdiff(off$meta$terms$random, "site_year_effect")
  vars <- .fitted_diagnostics(off)$variable
  expect_false(any(grepl("^site_year_effect\\[", vars)))
  expect_true(any(grepl("^site_effect\\[", vars)))
  expect_true("intercept" %in% vars)
})
