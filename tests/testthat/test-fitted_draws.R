test_that(".fitted_draws keeps only the estimated effects", {
  off <- weight_fit
  off$meta$terms$fixed <- setdiff(off$meta$terms$fixed, "bDensity")
  vars <- posterior::variables(.fitted_draws(off))
  expect_false("bDensity" %in% vars)
  expect_setequal(vars, c(off$meta$terms$fixed, off$meta$terms$random))
  # the stored draws are untouched
  expect_true("bDensity" %in% posterior::variables(off$draws))
})
