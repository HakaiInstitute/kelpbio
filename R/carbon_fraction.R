# The carbon fraction of each sample's dry mass, the carbon model's response,
# from the lab's carbon mass (ug) and sample mass (mg).
carbon_fraction <- function(data) {
  data$carbon_mass_ug / 1000 / data$sample_mass_mg
}

# Warn, rather than exclude, when samples have a carbon fraction outside
# 0.10 to 0.50, the stoichiometric range for kelp tissue (ash content and the
# carbon fraction of brown-algal organic constituents; Pessarrodona et al. 2023).
# Values outside it usually mean a unit mistake or a failed analysis.
warn_carbon_fraction <- function(data, x_name) {
  fraction <- carbon_fraction(data)
  n <- sum(fraction < 0.10 | fraction > 0.50)
  if (n > 0L) {
    # cli::qty(n) restates the count for the verb, since x_name sits between them.
    cli::cli_warn(c(
      "{n} sample{?s} in {x_name} {cli::qty(n)}{?has a/have} carbon fraction{?s} outside 0.10 to 0.50, the plausible range for kelp tissue.",
      i = "Check that {.field carbon_mass_ug} is in micrograms and {.field sample_mass_mg} in milligrams."
    ))
  }
  invisible(data)
}
