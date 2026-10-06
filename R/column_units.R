# Expected unit of each data column that has one, keyed by column name. Column
# names are shared across models, so a sub-model reusing a column reuses its unit.
# Read by the unit and range warnings.
column_units <- c(
  diameter_mm = "millimetres",
  weight_kg = "kilograms",
  stipes_m2 = "stipes per m\u00b2",
  area_m2 = "square metres",
  wet_mass_g = "grams",
  dry_mass_g = "grams",
  sample_mass_mg = "milligrams",
  carbon_mass_ug = "micrograms",
  canopy_area_m2 = "square metres",
  plot_area_m2 = "square metres",
  tide_height_m = "metres"
)
