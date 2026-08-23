test_that(".group_vars is the package-wide grouping set", {
  expect_identical(.group_vars(), c("site", "year"))
})

test_that(".fit_levels reads a factor's fitted levels, empty when unused", {
  expect_identical(.fit_levels(weight_fit, "site"), weight_fit$meta$site_levels)
  expect_identical(.fit_levels(weight_fit, "year"), weight_fit$meta$year_levels)
  # an intercept-only model records no levels at all
  none <- structure(list(meta = list()), class = "kb_fit")
  expect_length(.fit_levels(none, "site"), 0L)
  expect_length(.fit_levels(none, "year"), 0L)
})
