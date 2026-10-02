test_that("column_units names the unit of each unit-bearing column", {
  expect_named(column_units, c("diameter_mm", "weight_kg", "stipes_m2"))
  expect_identical(column_units[["diameter_mm"]], "millimetres")
  expect_identical(column_units[["weight_kg"]], "kilograms")
})
