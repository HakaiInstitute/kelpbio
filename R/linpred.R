# Link-scale mean, an rvar over grid rows, mirroring inst/stan/*.stan
# (decisions/prediction-engine.md). A caller evaluating the mean in pieces
# passes `effects` resolved once, so a sampled new level is one draw throughout.
.linpred <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL,
  effects = NULL
) {
  UseMethod(".linpred")
}

#' @export
.linpred.default <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL,
  effects = NULL
) {
  .abort_no_method(fit, call = NULL)
}

# Packard's three-parameter power function; the group effects scale the
# size-dependent part and leave the floor common.
#' @export
.linpred.kb_fit_weight_nereo <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL,
  effects = .group_effects(fit, grid, new_levels, representative_site)
) {
  draws <- fit$draws
  log_x <- log(grid$diameter_mm) - log(fit$meta$predictor_ref)
  log_alpha <- draws$intercept + effects
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
  floor <- if (.floor_on(fit)) draws$weight_floor else 0
  log(floor + exp(log_alpha + draws$diameter_power * log_x))
}

#' @export
.linpred.kb_fit_weight_macro <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL,
  effects = .group_effects(fit, grid, new_levels, representative_site)
) {
  draws <- fit$draws
  log_fc <- log(grid$fronds) - log(fit$meta$predictor_ref)
  draws$intercept + draws$fronds_slope * log_fc + effects
}

#' @export
.linpred.kb_fit_size <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL,
  effects = .group_effects(fit, grid, new_levels, representative_site)
) {
  fit$draws$intercept + effects
}

#' @export
.linpred.kb_fit_density <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL,
  effects = .group_effects(fit, grid, new_levels, representative_site)
) {
  fit$draws$intercept + effects
}

# Adding a zero vector broadcasts the scalar rvar over the rows.
#' @export
.linpred.kb_fit_wetdry <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL,
  effects = NULL
) {
  fit$draws$intercept + rep(0, nrow(grid))
}

#' @export
.linpred.kb_fit_carbon <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL,
  effects = NULL
) {
  fit$draws$intercept + rep(0, nrow(grid))
}

#' @export
.linpred.kb_fit_cover_biomass <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL,
  effects = .group_effects(fit, grid, new_levels, representative_site)
) {
  draws <- fit$draws
  cover <- tide_corrected_cover(grid, draws$tide_height_slope)
  log(draws$biomass_floor + draws$cover_slope * exp(effects) * cover)
}

# Summed link-scale group effects. representative_site borrows only the site
# effect. A fit without site:year has no such draws, so it adds 0.
.group_effects <- function(fit, grid, new_levels, representative_site) {
  draws <- fit$draws
  ix <- .grid_indices(fit, grid, representative_site)
  re_site <- resolve_re1(draws$site_effect, ix$site, new_levels, draws$sd_site, ix$rep)
  re_year <- resolve_re1(draws$year_effect, ix$year, new_levels, draws$sd_year)
  re_sy <- if (.site_year_on(fit)) {
    observed <- site_year_key(re_labels(ix$site), re_labels(ix$year)) %in%
      fit$meta$site_year_levels
    resolve_re2(
      draws$site_year_effect,
      ix$site,
      ix$year,
      observed,
      new_levels,
      draws$sd_site_year
    )
  } else {
    0
  }
  re_site + re_year + re_sy
}

# Link-scale mean at the observed rows, offset included. Every level is fitted,
# so new_levels is immaterial.
.linpred_obs <- function(fit, call = rlang::caller_env()) {
  .chk_observed_data(fit, call = call)
  grid <- tibble::as_tibble(fit$data)
  .linpred(fit, grid, new_levels = "average") + grid_offset(fit, grid)
}

# new_data (or the observed data) as a grid plus its link-scale linpred.
# `offset = FALSE` gives a rate model's rate at any rows (decisions/prediction-engine.md).
data_linpred <- function(
  fit,
  new_data,
  new_levels,
  representative_site = NULL,
  offset = TRUE,
  call = rlang::caller_env()
) {
  .chk_kb_fit(fit, call = call)
  new_levels <- rlang::arg_match(
    new_levels,
    c("average", "sample"),
    error_call = call
  )
  if (is.null(new_data)) {
    .chk_observed_data(
      fit,
      hint = "Supply {.arg new_data}, or fit the model to data.",
      call = call
    )
    grid <- tibble::as_tibble(fit$data)
  } else {
    .with_call(.chk_new_data(fit, new_data), call)
    grid <- tibble::as_tibble(new_data)
    # Excludes cover, which is derived rather than a data column.
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
