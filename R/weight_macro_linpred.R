# Single R-side source of the Macrocystis weight-model mean (log scale), as a
# posterior rvar over grid rows. Returns log(eWeight) so the shared prediction
# faces reuse the nereo path (posterior_epred exponentiates); for the Gamma mean
# the exponential is exact. Reuses the shared random-effect resolvers in
# weight_nereo_linpred.R (resolve_re1/resolve_re2). Macro differs from nereo: a
# linear (not quadratic) log-predictor, no site slope, and a standalone year main
# effect (bYear) in addition to site and site:year.
.weight_macro_linpred <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  draws <- fit$draws
  n <- nrow(grid)
  log_fc <- log(grid$fronds) - log(fit$meta$fronds_ref)

  si <- if ("site" %in% names(grid)) {
    match(as.character(grid$site), fit$meta$site_levels)
  } else {
    rep(NA_integer_, n)
  }
  yi <- if ("year" %in% names(grid)) {
    match(as.character(grid$year), fit$meta$year_levels)
  } else {
    rep(NA_integer_, n)
  }

  rep_idx <- if (!is.null(representative_site)) {
    match(representative_site, fit$meta$site_levels)
  } else {
    NULL
  }

  re_site <- resolve_re1(draws$bSite, si, new_levels, draws$sSite, rep_idx)
  # Year enters as a standalone main effect (unlike nereo). representative_site
  # borrows only the site intercept, so year follows new_levels regardless.
  re_year <- resolve_re1(draws$bYear, yi, new_levels, draws$sYear)
  # When the fit omitted the site:year effect its draws are prior-only noise, so
  # predictions must add nothing rather than reintroduce spurious variation.
  re_sy <- if (isFALSE(fit$meta$site_year_on)) {
    0
  } else {
    resolve_re2(draws$bSiteYear, si, yi, new_levels, draws$sSiteYear)
  }

  draws$bWeight +
    draws$bFronds * log_fc +
    re_site +
    re_year +
    re_sy
}
