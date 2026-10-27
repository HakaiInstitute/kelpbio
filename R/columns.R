# Expected unit of each data column that has one, read by the unit and range
# warnings. A sub-model reusing a column reuses its unit.
column_units <- c(
  diameter_mm = "millimetres",
  weight_kg = "kilograms",
  survey_area_m2 = "square metres",
  wet_mass_g = "grams",
  dry_mass_g = "grams",
  sample_mass_mg = "milligrams",
  carbon_mass_ug = "micrograms",
  nitrogen_mass_ug = "micrograms",
  canopy_area_m2 = "square metres",
  plot_area_m2 = "square metres",
  classified_area_m2 = "square metres",
  canopy_tide_height_m = "metres"
)

# Column-qualified name for chk error messages (bboudata convention).
column_xname <- function(x_name, col) {
  paste0("Column `", col, "` of ", x_name)
}
