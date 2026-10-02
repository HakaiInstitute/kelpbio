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

  re_site <- resolve_re1(draws$bSite, ix$site, new_levels, draws$sSite, ix$rep)
  # representative_site borrows only the site effect, so year follows new_levels.
  re_year <- resolve_re1(draws$bYear, ix$year, new_levels, draws$sYear)
  # When the fit omitted the site:year effect its draws are prior-only noise, so
  # predictions must add nothing rather than reintroduce spurious variation.
  re_sy <- if (.site_year_on(fit)) {
    resolve_re2(draws$bSiteYear, ix$site, ix$year, new_levels, draws$sSiteYear)
  } else {
    0
  }

  log_alpha <- draws$bWeight + re_site + re_year + re_sy
  if (.density_on(fit)) {
    density <- standardised_density(
      grid,
      TRUE,
      fit$meta$density_mean,
      fit$meta$density_sd,
      fit$meta$density_levels
    )
    log_alpha <- log_alpha + draws$bDensity * density
  }
  # A power-law fit has no floor; its bFloor draws are prior-only.
  floor <- if (.floor_on(fit)) draws$bFloor else 0
  log(floor + exp(log_alpha + draws$bPower * log_x))
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

  re_site <- resolve_re1(draws$bSite, ix$site, new_levels, draws$sSite, ix$rep)
  # Year enters as a standalone main effect (unlike nereo). representative_site
  # borrows only the site intercept, so year follows new_levels regardless.
  re_year <- resolve_re1(draws$bYear, ix$year, new_levels, draws$sYear)
  # When the fit omitted the site:year effect its draws are prior-only noise, so
  # predictions must add nothing rather than reintroduce spurious variation.
  re_sy <- if (.site_year_on(fit)) {
    resolve_re2(draws$bSiteYear, ix$site, ix$year, new_levels, draws$sSiteYear)
  } else {
    0
  }

  draws$bWeight +
    draws$bFronds * log_fc +
    re_site +
    re_year +
    re_sy
}

# Size- and density-model means (log scale), posterior rvars over grid rows,
# mirroring inst/stan/size_*.stan and inst/stan/density_*.stan. Every species
# shares the structure (an intercept plus site, year, and site:year effects, no
# predictor) and differs only in the intercept's name, so each method passes its
# intercept to .linpred_groups(). The density offset is added by the callers, as
# for every model.
#' @export
.linpred.kb_fit_size_nereo <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  .linpred_groups(fit, fit$draws$bDiameter, grid, new_levels, representative_site)
}

#' @export
.linpred.kb_fit_size_macro <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  .linpred_groups(fit, fit$draws$bFronds, grid, new_levels, representative_site)
}

#' @export
.linpred.kb_fit_density_nereo <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  .linpred_groups(fit, fit$draws$bStipes, grid, new_levels, representative_site)
}

#' @export
.linpred.kb_fit_density_macro <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  .linpred_groups(fit, fit$draws$bPlants, grid, new_levels, representative_site)
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

  re_site <- resolve_re1(draws$bSite, ix$site, new_levels, draws$sSite, ix$rep)
  # representative_site borrows only the site effect, so year follows new_levels.
  re_year <- resolve_re1(draws$bYear, ix$year, new_levels, draws$sYear)
  # When the fit omitted the site:year effect its draws are prior-only noise, so
  # predictions must add nothing rather than reintroduce spurious variation.
  re_sy <- if (.site_year_on(fit)) {
    resolve_re2(draws$bSiteYear, ix$site, ix$year, new_levels, draws$sSiteYear)
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
# The offset comes from the grid, so what this returns is fixed by the rows it was
# given rather than by an argument: supplied rows carry their own survey effort.
data_linpred <- function(
  fit,
  new_data,
  new_levels,
  representative_site = NULL
) {
  .chk_kb_fit(fit)
  new_levels <- rlang::arg_match(new_levels, c("sample", "average"))
  if (is.null(new_data)) {
    # fit$data already passed its model's data check at fit time.
    .chk_observed_data(fit)
    grid <- tibble::as_tibble(fit$data)
  } else {
    .chk_new_data(fit, new_data)
    grid <- tibble::as_tibble(new_data)
    predictor <- fit$meta[["predictor"]]
    if (!is.null(predictor)) {
      warn_outside_range(fit, grid[[predictor]], predictor)
    }
    if (.density_on(fit) && "stipes_m2" %in% names(grid)) {
      warn_outside_range(fit, grid$stipes_m2, "stipes_m2", lower = FALSE)
    }
  }
  list(
    grid = grid,
    group_vars = intersect(.group_vars(), names(grid)),
    linpred = .linpred(fit, grid, new_levels, representative_site) +
      grid_offset(fit, grid)
  )
}
