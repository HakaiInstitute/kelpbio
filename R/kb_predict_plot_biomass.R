#' Predict Plot Biomass from the Component Models
#'
#' Combine weight, size, and density fits into the expected biomass per m² of
#' each site-year surveyed for density, as wet, dry, or carbon biomass.
#'
#' @details
#' For each posterior draw, wet biomass is the site-year's expected density per
#' m² times its mean plant weight: the expected weight at size averaged over the
#' site-year's size distribution. The size distribution is truncated above at the
#' largest size in the size fit's data, since plant size has a ceiling the
#' distribution cannot represent; above the largest weighed size, the weight
#' allometry is extrapolated. `n_plants` sizes are taken at evenly spaced
#' quantiles of the distribution, so the average is accurate to well under 1% at
#' the default.
#'
#' Dry biomass is wet biomass times the expected dry:wet ratio from `wetdry`, and
#' carbon biomass is dry biomass times the expected carbon fraction from
#' `carbon`, in grams. Both ratios are pooled over the samples their fits were
#' given, so for a season-specific ratio fit them to that season's samples.
#'
#' A site-year that the weight or size fit did not observe uses that fit's site
#' and year effects where it has them, and otherwise follows `new_levels` or
#' `representative_site`, as in [kb_predict_weight()]. `weight_support` and
#' `size_support` show what each fit has for the site-year, from most to least
#' local: `"site-year"` (that site-year's own data), `"site, year"` (its site and
#' its year, but not together), `"site"`, `"year"`, or `"none"`; the less local,
#' the more the estimate borrows from other site-years. With `new_levels = "sample"`
#' the results vary between calls; set a seed with `set.seed()` for reproducible
#' intervals. For a *Nereocystis* weight fit with a density effect, each
#' site-year uses the stipe density observed in `density`'s data.
#'
#' The fits must be of the same species and have the same number of posterior
#' draws.
#'
#' The work grows with the number of site-years and draws, so `progress = "bar"`
#' shows a console progress bar, and `progress_dir` records progress for
#' [kb_progress()] to read from another R process, such as a Shiny app running
#' the prediction in the background.
#'
#' @inheritParams params
#' @param weight A `kb_fit_weight` object.
#' @param size A `kb_fit_size` object.
#' @param density A `kb_fit_density` object. Its site-years are the rows of the
#'   result.
#' @param wetdry A `kb_fit_wetdry` object, required for dry and carbon biomass,
#'   or `NULL`.
#' @param carbon A `kb_fit_carbon` object, required for carbon biomass, or
#'   `NULL`.
#' @param ... Unused.
#' @param measure A string, one of `"wet"` (kg/m²), `"dry"` (kg/m²), or
#'   `"carbon"` (g C/m²), giving the biomass to predict.
#' @param new_levels A string, one of `"sample"` (the default) or `"average"`,
#'   controlling how a site or year the weight or size fit never saw is treated:
#'   `"sample"` draws its effect from the fitted distribution, so the interval
#'   includes the variation between sites or years, as suits an estimate for that
#'   particular site-year; `"average"` holds it at zero (the typical site or
#'   year).
#' @param representative_site A character vector of sites fitted in both
#'   `weight` and `size`, or `NULL`. When supplied, a site either fit never saw
#'   takes the named sites' effects (the per-draw average when several are
#'   named) instead of the `new_levels` treatment.
#' @param n_plants A whole number of plants averaged per draw to compute the mean
#'   plant weight.
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
  .chk_progress_dir(progress_dir)
  new_levels <- rlang::arg_match(new_levels)
  .chk_kb_fit_weight(weight)
  .chk_kb_fit_size(size)
  .chk_kb_fit_density(density)
  if (!.vld_observed_data(density)) {
    cli::cli_abort("{.arg density} has no observed site-years to predict at.")
  }
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
  .chk_summary_args(conf_level, estimate, sig_fig)

  grid <- plot_biomass_grid(weight, size, density)
  groups <- grid[c("site", "year")]

  # Expected density per m^2: every row is an observed site-year of the density
  # fit, so its own effects apply, and the grid holds no area, so no offset.
  density_draws <- posterior::draws_of(.epred(
    density,
    .linpred(density, groups, new_levels)
  ))

  size_lp <- posterior::draws_of(
    .linpred(size, groups, new_levels, representative_site)
  )
  upper <- max(size$data[[size$meta$response]])
  # Evenly spaced quantiles: the midpoints of n_plants equal-probability strata.
  u <- (seq_len(n_plants) - 0.5) / n_plants

  # One step per site-year: the size draws and weight evaluations dominate.
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
      new_levels,
      representative_site
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

# Plant sizes for one site-year, D x length(u): the size distribution's
# quantiles at probabilities u, per draw, truncated above at `upper` (the
# distribution is renormalised below it). `lp` is the site-year's link-scale
# mean, one value per draw.
.plant_sizes <- function(fit, lp, upper, u) {
  UseMethod(".plant_sizes")
}

#' @export
.plant_sizes.default <- function(fit, lp, upper, u) {
  .abort_no_method(x = fit, call = NULL)
}

# Weibull with mean exp(lp) and shape shape; diameters in (0, upper].
#' @export
.plant_sizes.kb_fit_size_nereo <- function(fit, lp, upper, u) {
  shape <- as.vector(posterior::draws_of(fit$draws$shape))
  scale <- weibull_scale(exp(lp), shape)
  # shape and scale recycle down each column of the D x n matrix, so element
  # (d, k) gets draw d's distribution.
  p <- outer(stats::pweibull(upper, shape, scale), u)
  matrix(stats::qweibull(p, shape, scale), nrow = length(lp))
}

# Zero-truncated negative binomial with untruncated mean exp(lp) and
# overdispersion dispersion; frond counts in [1, upper]. Each draw's quantiles are
# looked up in its cumulative distribution over 1 to upper, built once, which is
# several times faster than stats::qnbinom() and gives the same counts.
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
  # The smallest count whose cumulative probability reaches u is one more than
  # the number of counts below u.
  fronds <- vapply(
    seq_along(mu),
    function(d) findInterval(u, cdf[d, ], left.open = TRUE) + 1,
    numeric(length(u))
  )
  matrix(fronds, nrow = length(lp), byrow = TRUE)
}
