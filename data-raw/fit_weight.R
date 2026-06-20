# Build fit_weight, a slim pre-fit weight model for runnable examples and
# tests. Fitted to a downsampled data_weight_sim with reduced chains and
# draws so the object stays small (the stored log_lik / yrep generated quantities
# scale with the number of observations). Not for inference. Reproducibility
# comes from the sampler `seed`; the downsample uses set.seed().
#
# Requires the compiled package (run `devtools::load_all()` or
# `devtools::install()` first). Re-run whenever the Stan model or the kb_fit
# object structure changes. Run from the package root:
#   Rscript data-raw/fit_weight.R

devtools::load_all(quiet = TRUE)

# A few rows per site-year cell, keeping the full grid so by = "site" and
# by = c("site", "year") examples exercise every level.
set.seed(42)
keep_per_cell <- 2L
d <- do.call(rbind, by(
  data_weight_sim,
  list(data_weight_sim$site, data_weight_sim$year),
  function(df) df[sample(nrow(df), min(keep_per_cell, nrow(df))), ]
))
d$site <- droplevels(factor(d$site))
d$year <- droplevels(factor(d$year))
rownames(d) <- NULL

fit_weight <- kb_fit_weight(
  d,
  chains = 2L, niters = 400L, nthin = 1L, cores = 2L,
  quiet = TRUE, seed = 42L
)

usethis::use_data(fit_weight, overwrite = TRUE)
