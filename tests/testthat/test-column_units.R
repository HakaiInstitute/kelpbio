test_that("column_units names the unit of each unit-bearing column", {
  expect_named(column_units, c("diameter", "weight", "density"))
  expect_identical(column_units[["diameter"]], "millimetres")
  expect_identical(column_units[["weight"]], "kilograms")
})
