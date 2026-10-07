test_that("posterior loads with kelpbio, so stored draws work on load", {
  # Without the import, a bundled fit's rvars have no methods until some kelpbio
  # function loads posterior, and print as empty.
  expect_true("posterior" %in% names(getNamespaceImports("kelpbio")))
})
