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
# Packard's three-parameter power form on the centered diameter ratio, mirroring
# inst/stan/weight_nereo.stan: the site effect is a log-scale multiplier on a
# positive population exponent, so the exponent stays positive and the curve is
# monotone within every site.
#' @export
.linpred.kb_fit_weight_nereo <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  draws <- fit$draws
  ix <- .grid_indices(fit, grid, representative_site)
  log_dc <- log(grid$diameter) - log(fit$meta$predictor_ref)

  re_site <- resolve_re1(draws$bSite, ix$site, new_levels, draws$sSite, ix$rep)
  # representative_site borrows the site intercept and exponent, so both take
  # ix$rep; year is a standalone effect and follows new_levels regardless.
  re_power <- resolve_re1(
    draws$bSitePower,
    ix$site,
    new_levels,
    draws$sSitePower,
    ix$rep
  )
  re_year <- resolve_re1(draws$bYear, ix$year, new_levels, draws$sYear)
  # When the fit omitted the site:year effect its draws are prior-only noise, so
  # predictions must add nothing rather than reintroduce spurious variation.
  re_sy <- if (.site_year_on(fit)) {
    resolve_re2(draws$bSiteYear, ix$site, ix$year, new_levels, draws$sSiteYear)
  } else {
    0
  }

  power <- draws$bPower * exp(re_power)
  floor <- draws$bFloor

  draws$bWeight +
    re_site +
    re_year +
    log(floor + (1 - floor) * exp(power * log_dc)) +
    re_sy
}

# Macrocystis mean, returned on the log scale like nereo so the shared faces are
# common; for the Gamma the exponential is the mean exactly. Differs from nereo: a
# linear log-predictor, no site slope, and a standalone bYear.
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
  }
  list(
    grid = grid,
    group_vars = intersect(.group_vars(), names(grid)),
    linpred = .linpred(fit, grid, new_levels, representative_site) +
      grid_offset(fit, grid)
  )
}
