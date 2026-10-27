# Nitrogen fraction of dry mass from nitrogen mass (ug) and sample mass (mg).
nitrogen_fraction <- function(data) {
  data$nitrogen_mass_ug / 1000 / data$sample_mass_mg
}
