# Build data_wetdry_sim_macro, a small simulated wet/dry dataset for fast tests and
# runnable examples. Simulated from the wet/dry model (a Beta dry:wet mass ratio
# with a mean and precision common to all samples), with the mean ratio, precision,
# and wet masses close to the Hakai Institute lab samples (mean ratio 0.125, wet masses about 0.6 to 5 g), so it passes kb_check_data_wetdry_macro() and
# kb_fit_wetdry_macro() converges on it. Not for inference. Run from the package
# root:
#   Rscript data-raw/data_wetdry_sim_macro.R

set.seed(707)

n <- 200L
mu <- 0.125 # mean dry:wet ratio
precision <- 180 # Beta precision

wet_mass_g <- signif(stats::rlnorm(n, log(1.8), 0.5), 4)
ratio <- stats::rbeta(n, mu * precision, (1 - mu) * precision)
dry_mass_g <- signif(wet_mass_g * ratio, 4)

data_wetdry_sim_macro <- tibble::tibble(
  wet_mass_g = wet_mass_g,
  dry_mass_g = dry_mass_g
)

usethis::use_data(data_wetdry_sim_macro, overwrite = TRUE)
