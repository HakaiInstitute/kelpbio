test_that("accessors return expected shapes", {
  expect_type(rhat(weight_fit), "double")
  expect_type(ess(weight_fit), "double")
  expect_equal(nobs(weight_fit), nrow(weight_fit$data))
  expect_equal(nchains(weight_fit), 2L)
  expect_equal(npars(weight_fit), 10L)
  expect_true(nterms(weight_fit) > npars(weight_fit))
  expect_setequal(pars(weight_fit), c("bWeight30", "bDiameter", "bDiameter2", "sSite", "sSiteDiameter", "sSiteYear", "sWeight", "bSite", "bSiteDiameter", "bSiteYear"))
})
