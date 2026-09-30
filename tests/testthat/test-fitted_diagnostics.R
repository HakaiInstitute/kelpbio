test_that(".fitted_diagnostics keeps rows of estimated effects, indexed or not", {
  off <- weight_fit
  off$meta$terms$random <- setdiff(off$meta$terms$random, "bSiteYear")
  vars <- .fitted_diagnostics(off)$variable
  expect_false(any(grepl("^bSiteYear\\[", vars)))
  expect_true(any(grepl("^bSite\\[", vars)))
  expect_true("bWeight" %in% vars)
})
