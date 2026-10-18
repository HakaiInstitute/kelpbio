# Mean plant weight of each site-year in `groups` (columns `site` and `year`,
# either may be absent), D x N: the expected weight at size averaged over the
# site-year's Weibull size distribution, truncated above at the largest size in
# the size fit's data. Effects are resolved over all rows at once, so a sampled
# new site or year is one draw throughout. Shared by kb_predict_mean_weight()
# and the tallied path of kb_predict_biomass_survey(), so the two agree.
mean_weight_draws <- function(
  weight,
  size,
  groups,
  new_levels,
  representative_site,
  n_plants,
  progress,
  progress_dir
) {
  size_lp <- posterior::draws_of(
    .linpred(size, groups, new_levels, representative_site)
  )
  weight_effects <- posterior::draws_of(
    .group_effects(weight, groups, new_levels, representative_site)
  )
  upper <- max(size$data[[size$meta$response]])
  # Midpoints of n_plants equal-probability strata.
  u <- (seq_len(n_plants) - 0.5) / n_plants

  n_rows <- nrow(groups)
  reporter <- progress_reporter(progress, "Predicting mean weight")
  reporter$start(n_rows)
  write_prediction_progress(progress_dir, 0L, n_rows)
  out <- matrix(NA_real_, nrow = nrow(size_lp), ncol = n_rows)
  for (k in seq_len(n_rows)) {
    sizes <- plant_sizes(size, size_lp[, k], upper, u)
    out[, k] <- mean_plant_weight(weight, sizes, weight_effects[, k])
    reporter$update(k)
    write_prediction_progress(progress_dir, k, n_rows)
  }
  reporter$finish()
  out
}
