test_that(".fitted_draws keeps only the estimated effects", {
  off <- weight_fit
  off$meta$terms$fixed <- setdiff(off$meta$terms$fixed, "density_slope")
  vars <- posterior::variables(.fitted_draws(off))
  expect_false("density_slope" %in% vars)
  expect_setequal(vars, c(off$meta$terms$fixed, off$meta$terms$random))
  # the stored draws are untouched
  expect_true("density_slope" %in% posterior::variables(off$draws))
})
