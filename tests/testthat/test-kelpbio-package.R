test_that("posterior loads with kelpbio, so stored draws work on load", {
  # Otherwise a bundled fit's rvars print as empty until posterior is loaded.
  expect_true("posterior" %in% names(getNamespaceImports("kelpbio")))
})
