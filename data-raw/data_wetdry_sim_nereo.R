# Build data_wetdry_sim_nereo, a small simulated wet/dry dataset for fast tests and
# runnable examples. Simulated from the wet/dry model (a Beta dry:wet mass ratio
# with a mean and precision common to all samples), with the mean ratio, precision,
# and wet masses close to the Hakai Institute lab samples (mean ratio 0.088, wet masses about 0.1 to 60 g), so it passes kb_check_data_wetdry_nereo() and
# kb_fit_wetdry_nereo() converges on it. Not for inference. Run from the package
# root:
#   Rscript data-raw/data_wetdry_sim_nereo.R

set.seed(606)

n <- 300L
mu <- 0.088 # mean dry:wet ratio
precision <- 170 # Beta precision

wet_mass_g <- signif(stats::rlnorm(n, log(3.9), 0.9), 4)
ratio <- stats::rbeta(n, mu * precision, (1 - mu) * precision)
dry_mass_g <- signif(wet_mass_g * ratio, 4)

data_wetdry_sim_nereo <- tibble::tibble(
  wet_mass_g = wet_mass_g,
  dry_mass_g = dry_mass_g
)

usethis::use_data(data_wetdry_sim_nereo, overwrite = TRUE)
