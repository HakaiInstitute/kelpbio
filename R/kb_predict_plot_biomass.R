#' Predict Plot Biomass from the Component Models
#'
#' Combine weight, size, and density fits into the expected biomass per m² of
#' each site-year surveyed for density, as wet, dry, or carbon biomass.
#'
#' @details
#' For each posterior draw, wet biomass is the site-year's expected density per
#' m² times its mean plant weight: the expected weight at size averaged over the
#' site-year's size distribution. The size distribution is truncated above at
#' the largest size in the size fit's data; above the largest weighed size, the
#' weight allometry is extrapolated.
#'
#' Dry biomass is wet biomass times the expected dry:wet ratio from `wetdry`,
#' and carbon biomass is dry biomass times the expected carbon fraction from
#' `carbon`, in grams. Both ratios are pooled over their fits' samples (see
#' [kb_predict_wetdry()]).
#'
#' A site-year not in the weight or size fit uses that fit's site and year
#' effects where it has them, and otherwise follows `new_levels` or
#' `representative_site`. `weight_support` and `size_support` show what each fit
#' has for the site-year, from most to least local: `"site-year"` (that
#' site-year's own data), `"site, year"` (its site and its year, but not
#' together), `"site"`, `"year"`, or `"none"`; the less local, the more the
#' estimate borrows from other site-years. For a *Nereocystis* weight fit with a
#' density effect, each site-year uses the stipe density observed in `density`'s
#' data.
#'
#' The fits must be of the same species and have the same number of posterior
#' draws.
#'
#' @inheritParams params
#' @param weight A `kb_fit_weight` object.
#' @param size A `kb_fit_size` object.
#' @param density A `kb_fit_density` object.
#' @param wetdry A `kb_fit_wetdry` object, required for dry and carbon biomass,
#'   or `NULL`.
#' @param carbon A `kb_fit_carbon` object, required for carbon biomass, or
#'   `NULL`.
#' @param ... Unused.
#' @param measure A string, one of `"wet"` (kg/m²), `"dry"` (kg/m²), or
#'   `"carbon"` (g C/m²), giving the biomass to predict.
#' @param new_levels A string, one of `"sample"` (the default) or `"average"`,
#'   giving how a site or year not in the weight or size fit is treated:
#'   `"sample"` draws a new effect, so the interval includes the variation
#'   between sites or years; `"average"` uses the typical site or year.
#'   `"sample"` gives a different interval on each call; use `set.seed()` to
#'   reproduce it.
#' @param representative_site A character vector of sites in both the `weight`
#'   and `size` fits whose effects a new site takes (averaged when several are
#'   named), or `NULL` (the default) to follow `new_levels`.
#' @param n_plants A whole number of sizes averaged per draw to compute the
#'   mean plant weight; larger values are more precise and slower.
#' @param progress A string, one of `"bar"` (the default, a console progress
#'   bar) or `"none"` (silent).
#' @param progress_dir A string giving an existing directory in which to record
#'   progress for [kb_progress()], or `NULL` (the default) to record none.
#'
#' @return A `kb_predictions` object with one row per site-year in `density`'s
#'   data and columns `site`, `year`, `weight_support`, `size_support`, and
#'   `estimate`, `lower`, and `upper` summarising the posterior distribution of
#'   the expected biomass.
#' @family prediction
#' @export
#'
#' @examples
#' kb_predict_plot_biomass(
#'   fit_weight_sim_nereo,
#'   fit_size_sim_nereo,
#'   fit_density_sim_nereo
#' )
kb_predict_plot_biomass <- function(
  weight,
  size,
  density,
  wetdry = NULL,
  carbon = NULL,
  ...,
  measure = c("wet", "dry", "carbon"),
  new_levels = c("sample", "average"),
  representative_site = NULL,
  n_plants = 100L,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3,
  progress = c("bar", "none"),
  progress_dir = NULL
) {
  rlang::check_dots_empty()
  measure <- rlang::arg_match(measure)
  progress <- rlang::arg_match(progress)
  .with_call(.chk_progress_dir(progress_dir), rlang::current_env())
  new_levels <- rlang::arg_match(new_levels)
  .chk_kb_fit(weight, "kb_fit_weight")
  .chk_kb_fit(size, "kb_fit_size")
  .chk_kb_fit(density, "kb_fit_density")
  .chk_observed_data(
    density,
    hint = "{.arg density} must be fitted to observed site-years."
  )
  # The size distribution is truncated at the largest observed size.
  .chk_observed_data(
    size,
    hint = "{.arg size} must be fitted to observed plant sizes."
  )
  .chk_measure_fits(measure, wetdry, carbon)
  fits <- list(
    weight = weight,
    size = size,
    density = density,
    wetdry = wetdry,
    carbon = carbon
  )
  fits <- fits[!vapply(fits, is.null, logical(1))]
  .chk_same_species(fits)
  .chk_same_ndraws(fits)
  .chk_representative_site(weight, representative_site)
  .chk_representative_site(size, representative_site)
  chk::chk_whole_number(n_plants)
  chk::chk_gte(n_plants, value = 1)
  .chk_finite(n_plants, "`n_plants`")
  .chk_summary_args(conf_level, estimate, sig_fig)

  grid <- plot_biomass_grid(weight, size, density)
  if (.density_on(weight)) {
    warn_outside_range(weight, grid$stipes_m2, "stipes_m2", lower = FALSE)
  }
  groups <- grid[c("site", "year")]

  # Per m^2: the grid holds no area column, so no offset.
  density_draws <- posterior::draws_of(.epred(
    density,
    .linpred(density, groups, new_levels)
  ))

  size_lp <- posterior::draws_of(
    .linpred(size, groups, new_levels, representative_site)
  )
  # Resolved once so a new site or year takes one weight effect throughout.
  weight_effects <- posterior::draws_of(
    .group_effects(weight, groups, new_levels, representative_site)
  )
  upper <- max(size$data[[size$meta$response]])
  # Midpoints of n_plants equal-probability strata.
  u <- (seq_len(n_plants) - 0.5) / n_plants

  n_rows <- nrow(grid)
  reporter <- progress_reporter(progress, "Predicting biomass")
  reporter$start(n_rows)
  write_prediction_progress(progress_dir, 0L, n_rows)
  weight_draws <- matrix(NA_real_, nrow = nrow(density_draws), ncol = n_rows)
  for (k in seq_len(n_rows)) {
    sizes <- .plant_sizes(size, size_lp[, k], upper, u)
    weight_draws[, k] <- mean_plant_weight(
      weight,
      grid[k, ],
      sizes,
      weight_effects[, k]
    )
    reporter$update(k)
    write_prediction_progress(progress_dir, k, n_rows)
  }
  reporter$finish()

  biomass <- density_draws * weight_draws
  if (measure %in% c("dry", "carbon")) {
    biomass <- biomass * population_draws(wetdry)
  }
  if (measure == "carbon") {
    biomass <- biomass * population_draws(carbon) * 1000
  }

  summarise_draws_rows(
    grid[c("site", "year", "weight_support", "size_support")],
    posterior::rvar(biomass),
    group_vars = c("site", "year"),
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    curve = FALSE,
    predictor = NULL,
    response = c(
      wet = "biomass_kg_m2",
      dry = "dry_biomass_kg_m2",
      carbon = "carbon_biomass_g_m2"
    )[[measure]]
  )
}

# D x length(u) quantiles of one site-year's size distribution, per draw,
# truncated above at `upper` and renormalised. `lp` has one value per draw.
.plant_sizes <- function(fit, lp, upper, u) {
  UseMethod(".plant_sizes")
}

#' @export
.plant_sizes.default <- function(fit, lp, upper, u) {
  .abort_no_method(fit, call = NULL)
}

#' @export
.plant_sizes.kb_fit_size_nereo <- function(fit, lp, upper, u) {
  shape <- as.vector(posterior::draws_of(fit$draws$shape))
  scale <- weibull_scale(exp(lp), shape)
  # shape and scale recycle down columns, so row d gets draw d's distribution.
  p <- outer(stats::pweibull(upper, shape, scale), u)
  matrix(stats::qweibull(p, shape, scale), nrow = length(lp))
}

# Looks quantiles up in each draw's CDF over 1 to upper, several times faster
# than stats::qnbinom() with the same counts.
#' @export
.plant_sizes.kb_fit_size_macro <- function(fit, lp, upper, u) {
  size <- 1 / as.vector(posterior::draws_of(fit$draws$dispersion))
  mu <- exp(lp)
  p0 <- stats::pnbinom(0, mu = mu, size = size)
  # D x upper: P(X <= f | 1 <= X <= upper) for f = 1, ..., upper.
  cdf <- vapply(
    seq_len(upper),
    function(f) stats::pnbinom(f, mu = mu, size = size) - p0,
    numeric(length(mu))
  )
  cdf <- cdf / cdf[, upper]
  fronds <- vapply(
    seq_along(mu),
    function(d) findInterval(u, cdf[d, ], left.open = TRUE) + 1,
    numeric(length(u))
  )
  matrix(fronds, nrow = length(lp), byrow = TRUE)
}
