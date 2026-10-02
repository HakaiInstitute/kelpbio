# Build fit_density_sim_nereo, a slim pre-fit density model for runnable
# examples and tests. Fitted to the whole data_density_sim_nereo with reduced
# chains and draws so the object stays small; its size is set by the draw count
# alone, since no per-observation quantities are stored. Not for inference.
# Reproducibility comes from the sampler `seed`.
#
# Requires the compiled package (run `devtools::install()` first; a Stan change
# is only picked up after install). Re-run whenever the Stan model, the
# simulated dataset, or the kb_fit object structure changes. Run from the
# package root:
#   Rscript data-raw/fit_density_sim_nereo.R

devtools::load_all(quiet = TRUE)

fit_density_sim_nereo <- kb_fit_density_nereo(
  data_density_sim_nereo,
  chains = 3L,
  niters = 500L,
  # nthin multiplies the sampling iterations while holding the saved draw count
  # fixed, so these deliberately small objects clear the convergence thresholds
  # without growing. adapt_delta is raised above the 0.95 default for the same
  # reason.
  nthin = 3L,
  cores = 4L,
  progress = "bar",
  seed = 42L,
  control = list(adapt_delta = 0.999)
)

usethis::use_data(fit_density_sim_nereo, overwrite = TRUE)
