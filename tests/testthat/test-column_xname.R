test_that("column_xname names the column and its data frame", {
  expect_identical(column_xname("`data`", "site"), "Column `site` of `data`")
})
