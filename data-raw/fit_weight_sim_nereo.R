# Build fit_weight_sim_nereo, a slim pre-fit weight model for runnable examples and
# tests. Fitted to a downsampled data_weight_sim_nereo with reduced chains and
# draws so the object stays small (the stored log_lik / yrep generated quantities
# scale with the number of observations). Not for inference. Reproducibility
# comes from the sampler `seed`; the downsample uses set.seed().
#
# Requires the compiled package (run `devtools::load_all()` or
# `devtools::install()` first). Re-run whenever the Stan model or the kb_fit
# object structure changes. Run from the package root:
#   Rscript data-raw/fit_weight_sim_nereo.R

devtools::load_all(quiet = TRUE)

# Several rows per site-year cell, keeping the full grid so by = "site" and
# by = c("site", "year") examples exercise every level. Enough observations to
# identify the site intercept and site slope SDs (a sparser sample lets the
# regularizing priors shrink both toward zero).
set.seed(42)
keep_per_cell <- 6L
d <- do.call(
  rbind,
  by(
    data_weight_sim_nereo,
    list(data_weight_sim_nereo$site, data_weight_sim_nereo$year),
    function(df) df[sample(nrow(df), min(keep_per_cell, nrow(df))), ]
  )
)
d$site <- droplevels(factor(d$site))
d$year <- droplevels(factor(d$year))
rownames(d) <- NULL

fit_weight_sim_nereo <- kb_fit_weight_nereo(
  d,
  chains = 2L,
  niters = 400L,
  nthin = 1L,
  cores = 2L,
  quiet = TRUE,
  seed = 42L
)

usethis::use_data(fit_weight_sim_nereo, overwrite = TRUE)
