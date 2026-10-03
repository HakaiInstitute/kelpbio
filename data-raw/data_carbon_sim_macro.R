# Build data_carbon_sim_macro, a small simulated carbon dataset for fast tests and
# runnable examples. Simulated from the carbon model (a Beta carbon fraction with a
# mean and precision common to all samples), with the mean, precision, and sample
# masses close to the Hakai Institute lab samples (mean fraction 0.317), so it passes
# kb_check_data_carbon_macro() and kb_fit_carbon_macro() converges on it. Not for
# inference. Run from the package root:
#   Rscript data-raw/data_carbon_sim_macro.R

set.seed(909)

n <- 190L
mu <- 0.317 # mean carbon fraction of dry mass
precision <- 130 # Beta precision

# Sample masses as the isotope lab weighs them (1.8 to 3.0 mg), with the carbon
# mass in micrograms.
sample_mass_mg <- round(stats::runif(n, 1.8, 3.0), 2)
fraction <- stats::rbeta(n, mu * precision, (1 - mu) * precision)

data_carbon_sim_macro <- tibble::tibble(
  sample_mass_mg = sample_mass_mg,
  carbon_mass_ug = round(fraction * sample_mass_mg * 1000, 2)
)

usethis::use_data(data_carbon_sim_macro, overwrite = TRUE)
