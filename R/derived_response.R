# Response column of a biomass verb, named for its measure and scale. Carbon and
# nitrogen per m^2 are in grams, their totals in kilograms.
derived_response <- function(measure, per_area) {
  if (per_area) {
    c(
      wet = "biomass_kg_m2",
      dry = "dry_biomass_kg_m2",
      carbon = "carbon_biomass_g_m2",
      nitrogen = "nitrogen_biomass_g_m2"
    )[[measure]]
  } else {
    c(
      wet = "biomass_kg",
      dry = "dry_biomass_kg",
      carbon = "carbon_biomass_kg",
      nitrogen = "nitrogen_biomass_kg"
    )[[measure]]
  }
}
