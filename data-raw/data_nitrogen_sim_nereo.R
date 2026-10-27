# Build data_nitrogen_sim_nereo, a small simulated nitrogen dataset for fast tests and
# runnable examples. Simulated from the nitrogen model (a Beta nitrogen fraction with a
# mean and precision common to all samples), with the mean, precision, and sample
# masses close to the Hakai Institute lab samples (mean fraction 0.019), so it passes
# kb_check_data_nitrogen_nereo() and kb_fit_nitrogen_nereo() converges on it. Not for
# inference. Run from the package root:
#   Rscript data-raw/data_nitrogen_sim_nereo.R

set.seed(818)

n <- 188L
mu <- 0.019 # mean nitrogen fraction of dry mass
precision <- 250 # Beta precision

# Sample masses as the isotope lab weighs them (1.8 to 3.0 mg), with the nitrogen
# mass in micrograms.
sample_mass_mg <- round(stats::runif(n, 1.8, 3.0), 2)
fraction <- stats::rbeta(n, mu * precision, (1 - mu) * precision)

data_nitrogen_sim_nereo <- tibble::tibble(
  sample_mass_mg = sample_mass_mg,
  nitrogen_mass_ug = round(fraction * sample_mass_mg * 1000, 2)
)

usethis::use_data(data_nitrogen_sim_nereo, overwrite = TRUE)
