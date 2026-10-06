test_that("column_units names the unit of each unit-bearing column", {
  expect_named(
    column_units,
    c(
      "diameter_mm",
      "weight_kg",
      "stipes_m2",
      "area_m2",
      "wet_mass_g",
      "dry_mass_g",
      "sample_mass_mg",
      "carbon_mass_ug",
      "canopy_area_m2",
      "plot_area_m2",
      "site_area_m2",
      "tide_height_m"
    )
  )
  expect_identical(column_units[["diameter_mm"]], "millimetres")
  expect_identical(column_units[["weight_kg"]], "kilograms")
  expect_identical(column_units[["area_m2"]], "square metres")
  expect_identical(column_units[["wet_mass_g"]], "grams")
})
