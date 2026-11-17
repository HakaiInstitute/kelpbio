test_that("column_units names the unit of each unit-bearing column", {
  expect_named(
    column_units,
    c(
      "diameter_mm",
      "weight_kg",
      "survey_area_m2",
      "wet_mass_g",
      "dry_mass_g",
      "sample_mass_mg",
      "carbon_mass_ug",
      "nitrogen_mass_ug",
      "canopy_area_m2",
      "plot_area_m2",
      "classified_area_m2",
      "canopy_tide_height_m"
    )
  )
  expect_identical(column_units[["diameter_mm"]], "millimetres")
  expect_identical(column_units[["weight_kg"]], "kilograms")
  expect_identical(column_units[["survey_area_m2"]], "square metres")
  expect_identical(column_units[["wet_mass_g"]], "grams")
})

test_that("column_xname names the column and its data frame", {
  expect_identical(column_xname("`data`", "site"), "Column `site` of `data`")
})

test_that("data_column_names gives the required or all columns", {
  expect_identical(
    data_column_names("size_census_macro"),
    c("survey_id", "fronds")
  )
  expect_identical(
    data_column_names("size_census_macro", required = FALSE),
    c("survey_id", "fronds", "partial")
  )
})

test_that("the dictionary units match column_units", {
  symbols <- c(
    mm = "millimetres",
    kg = "kilograms",
    g = "grams",
    mg = "milligrams",
    m = "metres"
  )
  symbols[["m²"]] <- "square metres"
  symbols[["µg"]] <- "micrograms"
  rows <- unique(data_columns[!is.na(data_columns$units), c("column", "units")])
  rows <- rows[rows$column != "biomass_kg_m2", ]
  expect_setequal(rows$column, names(column_units))
  expect_identical(
    unname(symbols[rows$units]),
    unname(column_units[rows$column])
  )
})

test_that("doc_data_columns lists the required and optional columns", {
  expect_snapshot(cat(doc_data_columns("size_census_nereo")))
})
