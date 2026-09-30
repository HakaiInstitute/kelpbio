# Expected unit of each data column that has one, keyed by column name. Column
# names are shared across models, so a sub-model reusing a column reuses its unit.
# Read by the unit and range warnings.
column_units <- c(
  diameter = "millimetres",
  weight = "kilograms",
  density = "stipes per m²"
)
