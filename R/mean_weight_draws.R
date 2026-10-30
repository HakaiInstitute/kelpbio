# Mean plant weight of each site-year in `groups` (columns `site` and `year`,
# either may be absent), D x N: the expected weight at size averaged over the
# site-year's Weibull size distribution, truncated above at the largest size in
# the size fit's data. Effects are resolved over all rows at once, so a sampled
# new site or year is one draw throughout. Shared by kb_predict_mean_weight()
# and the tallied path of kb_predict_biomass_in_situ(), so the two agree.
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
  representative_site <- representative_sites(representative_site)
  size_lp <- posterior::draws_of(
    .linpred(size, groups, new_levels, representative_site$size)
  )
  weight_effects <- posterior::draws_of(
    .group_effects(weight, groups, new_levels, representative_site$weight)
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

# One representative_site per fit with site effects: a character vector applies
# to every fit, a list gives each fit its own (NULL where it names none).
representative_sites <- function(representative_site, fits = c("weight", "size")) {
  out <- lapply(fits, function(fit) {
    if (is.list(representative_site)) representative_site[[fit]] else representative_site
  })
  names(out) <- fits
  out
}

# D x length(u) quantiles of one site-year's Weibull size distribution, per
# draw, truncated above at `upper` and renormalised. `lp` has one value per draw.
plant_sizes <- function(fit, lp, upper, u) {
  shape <- as.vector(posterior::draws_of(fit$draws$shape))
  scale <- weibull_scale(exp(lp), shape)
  # shape and scale recycle down columns, so row d gets draw d's distribution.
  p <- outer(stats::pweibull(upper, shape, scale), u)
  matrix(stats::qweibull(p, shape, scale), nrow = length(lp))
}

# Mean expected weight of one site-year's plants, per draw (length D). `sizes`
# is D x n_plants. `effects` (length D) is resolved by the caller over every
# site-year at once, so a sampled new level is shared across them, and the
# plants need no site or year.
mean_plant_weight <- function(weight, sizes, effects) {
  n <- ncol(sizes)
  nchains <- posterior::nchains(weight$draws)
  plants <- tibble::tibble(.rows = n)
  plants[[weight$meta$predictor]] <- posterior::rvar(sizes, nchains = nchains)
  plant_effects <- posterior::rvar(
    matrix(effects, nrow = length(effects), ncol = n),
    nchains = nchains
  )
  expected <- .epred(
    weight,
    .linpred(weight, plants, new_levels = "average", effects = plant_effects)
  )
  rowMeans(posterior::draws_of(expected))
}
