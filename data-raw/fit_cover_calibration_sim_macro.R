# Build fit_cover_calibration_sim_macro, a slim pre-fit cover calibration model
# for runnable examples and tests. Fitted to the survey biomass from
# fit_weight_sim_macro, data_size_census_sim_macro, and data_in_situ_sim_macro, with reduced chains
# and draws so the object stays small; its size is set by the draw count alone,
# since no per-observation quantities are stored. Not for inference.
# Reproducibility comes from set.seed() for the survey biomass and the sampler
# `seed`.
#
# Requires the compiled package (run `devtools::install()` first; a Stan change
# is only picked up after install). Re-run whenever the Stan model, the
# simulated datasets, the weight or size pre-fits, or the kb_fit object
# structure changes. Run from the package root:
#   Rscript data-raw/fit_cover_calibration_sim_macro.R

devtools::load_all(quiet = TRUE)

set.seed(42)
biomass <- kb_predict_biomass_in_situ(
  fit_weight_sim_macro,
  data_size_census_sim_macro,
  data_in_situ_sim_macro,
  progress = "none"
)

fit_cover_calibration_sim_macro <- kb_fit_cover_calibration_macro(
  biomass,
  chains = 3L,
  niters = 500L,
  # nthin multiplies the sampling iterations while holding the saved draw count
  # fixed, so these deliberately small objects clear the convergence thresholds
  # without growing.
  nthin = 2L,
  cores = 4L,
  progress = "bar",
  seed = 42L
)

usethis::use_data(fit_cover_calibration_sim_macro, overwrite = TRUE)
