# Mean on the link scale, an rvar over grid rows. Every predict path routes here,
# so it is the single R-side source of the mean.
.linpred <- function(fit, grid, new_levels, representative_site = NULL) {
  UseMethod(".linpred")
}

#' @export
.linpred.default <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  .abort_no_method(x = fit, call = NULL)
}

# Nereocystis weight-model mean (log scale), a posterior rvar over grid rows.
# Packard's three-parameter power function on the diameter ratio, mirroring
# inst/stan/weight_nereo.stan: the random effects act on log(alpha), so they scale
# the size-dependent part of the weight and leave the floor common.
#' @export
.linpred.kb_fit_weight_nereo <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  draws <- fit$draws
  ix <- .grid_indices(fit, grid, representative_site)
  log_x <- log(grid$diameter_mm) - log(fit$meta$predictor_ref)

  re_site <- resolve_re1(draws$site_effect, ix$site, new_levels, draws$sd_site, ix$rep)
  # representative_site borrows only the site effect, so year follows new_levels.
  re_year <- resolve_re1(draws$year_effect, ix$year, new_levels, draws$sd_year)
  # When the fit omitted the site:year effect its draws are prior-only noise, so
  # predictions must add nothing rather than reintroduce spurious variation.
  re_sy <- if (.site_year_on(fit)) {
    resolve_re2(draws$site_year_effect, ix$site, ix$year, new_levels, draws$sd_site_year)
  } else {
    0
  }

  log_alpha <- draws$intercept + re_site + re_year + re_sy
  if (.density_on(fit)) {
    density <- standardised_density(
      grid,
      TRUE,
      fit$meta$density_mean,
      fit$meta$density_sd,
      fit$meta$density_levels
    )
    log_alpha <- log_alpha + draws$density_slope * density
  }
  # A power-law fit has no floor; its weight_floor draws are prior-only.
  floor <- if (.floor_on(fit)) draws$weight_floor else 0
  log(floor + exp(log_alpha + draws$diameter_power * log_x))
}

# Macrocystis mean, returned on the log scale like nereo so the shared faces are
# common; for the Gamma the exponential is the mean exactly. Differs from nereo: a
# log-linear predictor with no floor.
#' @export
.linpred.kb_fit_weight_macro <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  draws <- fit$draws
  ix <- .grid_indices(fit, grid, representative_site)
  log_fc <- log(grid$fronds) - log(fit$meta$predictor_ref)

  re_site <- resolve_re1(draws$site_effect, ix$site, new_levels, draws$sd_site, ix$rep)
  # Year enters as a standalone main effect (unlike nereo). representative_site
  # borrows only the site intercept, so year follows new_levels regardless.
  re_year <- resolve_re1(draws$year_effect, ix$year, new_levels, draws$sd_year)
  # When the fit omitted the site:year effect its draws are prior-only noise, so
  # predictions must add nothing rather than reintroduce spurious variation.
  re_sy <- if (.site_year_on(fit)) {
    resolve_re2(draws$site_year_effect, ix$site, ix$year, new_levels, draws$sd_site_year)
  } else {
    0
  }

  draws$intercept +
    draws$fronds_slope * log_fc +
    re_site +
    re_year +
    re_sy
}

# Size- and density-model means (log scale), posterior rvars over grid rows,
# mirroring inst/stan/size_*.stan and inst/stan/density_*.stan. Every species
# shares the structure (an intercept plus site, year, and site:year effects, no
# predictor), so each method passes its intercept to .linpred_groups(). The
# density offset is added by the callers, as for every model.
#' @export
.linpred.kb_fit_size_nereo <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  .linpred_groups(fit, fit$draws$intercept, grid, new_levels, representative_site)
}

#' @export
.linpred.kb_fit_size_macro <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  .linpred_groups(fit, fit$draws$intercept, grid, new_levels, representative_site)
}

#' @export
.linpred.kb_fit_density_nereo <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  .linpred_groups(fit, fit$draws$intercept, grid, new_levels, representative_site)
}

#' @export
.linpred.kb_fit_density_macro <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  .linpred_groups(fit, fit$draws$intercept, grid, new_levels, representative_site)
}

# Wet/dry mean (logit scale): one value for every row, since the model has no
# groups or predictor. Adding a zero vector broadcasts the scalar rvar over the
# grid rows.
#' @export
.linpred.kb_fit_wetdry <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  fit$draws$intercept + rep(0, nrow(grid))
}

# Carbon mean (logit scale): one value for every row, as for wet/dry.
#' @export
.linpred.kb_fit_carbon <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  fit$draws$intercept + rep(0, nrow(grid))
}

# Cover-model mean (log scale), mirroring inst/stan/cover_biomass.stan: a floor common to
# every site and year plus a canopy term proportional to tide-corrected cover, on
# which the site and year effects act. Both species share it.
#' @export
.linpred.kb_fit_cover_biomass <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  draws <- fit$draws
  ix <- .grid_indices(fit, grid, representative_site)

  re_site <- resolve_re1(draws$site_effect, ix$site, new_levels, draws$sd_site, ix$rep)
  # representative_site borrows only the site effect, so year follows new_levels.
  re_year <- resolve_re1(draws$year_effect, ix$year, new_levels, draws$sd_year)
  cover <- tide_corrected_cover(grid, draws$tide_height_slope)

  log(draws$biomass_floor + draws$cover_slope * exp(re_site + re_year) * cover)
}

.linpred_groups <- function(
  fit,
  intercept,
  grid,
  new_levels,
  representative_site
) {
  draws <- fit$draws
  ix <- .grid_indices(fit, grid, representative_site)

  re_site <- resolve_re1(draws$site_effect, ix$site, new_levels, draws$sd_site, ix$rep)
  # representative_site borrows only the site effect, so year follows new_levels.
  re_year <- resolve_re1(draws$year_effect, ix$year, new_levels, draws$sd_year)
  # When the fit omitted the site:year effect its draws are prior-only noise, so
  # predictions must add nothing rather than reintroduce spurious variation.
  re_sy <- if (.site_year_on(fit)) {
    resolve_re2(draws$site_year_effect, ix$site, ix$year, new_levels, draws$sd_site_year)
  } else {
    0
  }

  intercept + re_site + re_year + re_sy
}

# Link-scale mean at the observed rows. Every level is a fitted level, since
# meta$*_levels was taken from this same data frame at fit time, so new_levels is
# immaterial here.
#
# The offset is always added: these rows are observations, so they carry the
# survey effort the model was fitted against. It is 0 for a model with none.
.linpred_obs <- function(fit) {
  .chk_observed_data(fit)
  grid <- tibble::as_tibble(fit$data)
  .linpred(fit, grid, new_levels = "average") + grid_offset(fit, grid)
}

# Resolve new_data (or the observed data) into a grid plus its link-scale linpred.
# The offset comes from the grid: supplied rows carry their own survey effort, and
# rows without the offset column take one unit of it. `offset = FALSE` drops it,
# so a rate model returns its rate at any rows, including the observed data.
# `curve` passes on whether new_data is a kb_new_data() grid over a predictor.
data_linpred <- function(
  fit,
  new_data,
  new_levels,
  representative_site = NULL,
  offset = TRUE
) {
  .chk_kb_fit(fit)
  new_levels <- rlang::arg_match(new_levels, c("average", "sample"))
  if (is.null(new_data)) {
    # fit$data already passed its model's data check at fit time.
    .chk_observed_data(fit)
    grid <- tibble::as_tibble(fit$data)
  } else {
    .chk_new_data(fit, new_data)
    grid <- tibble::as_tibble(new_data)
    # A predictor the data hold as a column (not cover, which is derived).
    predictor <- intersect(fit$meta[["predictor"]], names(fit$data))
    if (length(predictor)) {
      warn_outside_range(fit, grid[[predictor]], predictor)
    }
    if (.density_on(fit) && "stipes_m2" %in% names(grid)) {
      warn_outside_range(fit, grid$stipes_m2, "stipes_m2", lower = FALSE)
    }
  }
  linpred <- .linpred(fit, grid, new_levels, representative_site)
  if (offset) {
    linpred <- linpred + grid_offset(fit, grid)
  }
  list(
    grid = grid,
    group_vars = intersect(.group_vars(), names(grid)),
    linpred = linpred,
    curve = isTRUE(attr(new_data, "kb_curve", exact = TRUE))
  )
}
