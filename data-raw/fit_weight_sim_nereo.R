# Build fit_weight_sim_nereo, a slim pre-fit weight model for runnable examples
# and tests. Fitted to the whole data_weight_sim_nereo (which is itself kept
# small, ~6 obs per site-year cell) with reduced chains and draws so the object
# stays small (the stored log_lik / yrep generated quantities scale with the
# number of observations). Not for inference. Reproducibility comes from the
# sampler `seed`.
#
# Requires the compiled package (run `devtools::load_all()` or
# `devtools::install()` first). Re-run whenever the Stan model, the simulated
# dataset, or the kb_fit object structure changes. Run from the package root:
#   Rscript data-raw/fit_weight_sim_nereo.R

devtools::load_all(quiet = TRUE)

fit_weight_sim_nereo <- kb_fit_weight_nereo(
  data_weight_sim_nereo,
  chains = 3L,
  niters = 500L,
  # nthin multiplies the sampling iterations while holding the saved draw count
  # fixed, so these deliberately small objects clear the convergence thresholds
  # without growing. adapt_delta is raised above the 0.95 default for the same
  # reason.
  nthin = 2L,
  cores = 4L,
  progress = "bar",
  seed = 42L,
  control = list(adapt_delta = 0.999)
)

usethis::use_data(fit_weight_sim_nereo, overwrite = TRUE)
