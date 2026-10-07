# Carbon fraction of dry mass from carbon mass (ug) and sample mass (mg).
carbon_fraction <- function(data) {
  data$carbon_mass_ug / 1000 / data$sample_mass_mg
}
