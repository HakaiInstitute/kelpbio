# Build data_carbon_sim_nereo, a small simulated carbon dataset for fast tests and
# runnable examples. Simulated from the carbon model (a Beta carbon fraction with a
# mean and precision common to all samples), with the mean, precision, and sample
# masses close to the Hakai Institute lab samples (mean fraction 0.263), so it passes
# kb_check_data_carbon_nereo() and kb_fit_carbon_nereo() converges on it. Not for
# inference. Run from the package root:
#   Rscript data-raw/data_carbon_sim_nereo.R

set.seed(808)

n <- 185L
mu <- 0.263 # mean carbon fraction of dry mass
precision <- 62 # Beta precision

# Sample masses as the isotope lab weighs them (1.8 to 3.0 mg), with the carbon
# mass in micrograms.
sample_mass_mg <- round(stats::runif(n, 1.8, 3.0), 2)
fraction <- stats::rbeta(n, mu * precision, (1 - mu) * precision)

data_carbon_sim_nereo <- tibble::tibble(
  sample_mass_mg = sample_mass_mg,
  carbon_mass_ug = round(fraction * sample_mass_mg * 1000, 2)
)

usethis::use_data(data_carbon_sim_nereo, overwrite = TRUE)
