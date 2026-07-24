# Single R-side source of the Nereocystis weight-model mean (log scale), as a
# posterior rvar over grid rows. All predict paths route through here.
.weight_nereo_linpred <- function(
  fit,
  grid,
  new_levels,
  representative_site = NULL
) {
  draws <- fit$draws
  n <- nrow(grid)
  log_dc <- log(grid$diameter) - log(fit$meta$diameter_ref)

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
  re_slope <- resolve_re1(
    draws$bSiteDiameter,
    si,
    new_levels,
    draws$sSiteDiameter,
    rep_idx
  )
  # When the fit omitted the site:year effect its draws are prior-only noise, so
  # predictions must add nothing rather than reintroduce spurious variation. A
  # missing flag (fits built before it was recorded) defaults to on, since those
  # fits always included the effect; only an explicit FALSE disables it.
  re_sy <- if (isFALSE(fit$meta$site_year_on)) {
    0
  } else {
    resolve_re2(draws$bSiteYear, si, yi, new_levels, draws$sSiteYear)
  }

  draws$bWeight +
    draws$bDiameter * log_dc +
    draws$bDiameter2 * log_dc^2 +
    re_site +
    re_slope * log_dc +
    re_sy
}

# new_levels is immaterial: every observed row is a known level.
.weight_nereo_linpred_obs <- function(fit) {
  .weight_nereo_linpred(
    fit,
    tibble::as_tibble(fit$data),
    new_levels = "average"
  )
}

weight_data_linpred <- function(
  fit,
  new_data,
  new_levels,
  representative_site = NULL
) {
  .chk_kb_fit_weight(fit)
  new_levels <- rlang::arg_match(new_levels, c("sample", "average"))
  if (is.null(new_data)) {
    # fit$data already passed kb_check_data_weight_nereo() at fit time.
    grid <- tibble::as_tibble(fit$data)
  } else {
    .chk_new_data_weight_nereo(new_data)
    grid <- tibble::as_tibble(new_data)
  }
  list(
    grid = grid,
    group_vars = intersect(c("site", "year"), names(grid)),
    linpred = .weight_nereo_linpred(fit, grid, new_levels, representative_site)
  )
}

weight_by_linpred <- function(fit, by, new_levels, diameter = NULL) {
  .chk_kb_fit_weight(fit)
  new_levels <- rlang::arg_match(new_levels, c("sample", "average"))
  by <- validate_by_weight(by)
  grid <- build_by_grid(fit, by, diameter)
  list(
    grid = grid,
    by = by,
    linpred = .weight_nereo_linpred(fit, grid, new_levels)
  )
}

validate_by_weight <- function(by) {
  if (is.null(by)) {
    by <- character(0)
  }
  chk::chk_character(by)
  valid <- c("site", "year")
  bad <- setdiff(by, valid)
  if (length(bad)) {
    cli::cli_abort(c(
      "Invalid {.arg by} value{?s}: {.val {bad}}.",
      i = "Available grouping factors: {.val {valid}}."
    ))
  }
  # Year has no main effect, only the site:year interaction.
  if ("year" %in% by && !"site" %in% by) {
    cli::cli_abort(c(
      "{.code by = \"year\"} is not available for the weight model.",
      i = "Year enters only through the site:year interaction (no year main effect).",
      i = "Use {.code by = NULL}, {.val site}, or {.code c(\"site\", \"year\")}."
    ))
  }
  by
}

build_by_grid <- function(fit, by, diameter = NULL) {
  if (is.null(diameter)) {
    rng <- range(fit$data$diameter, na.rm = TRUE)
    diameter <- seq(rng[1], rng[2], length.out = 30L)
  } else {
    chk::chk_numeric(diameter)
  }
  if (length(by) == 0) {
    return(tibble::tibble(diameter = diameter))
  }
  site_levels <- fit$meta$site_levels
  diameters <- tibble::tibble(diameter = diameter)
  if (setequal(by, "site")) {
    sites <- tibble::tibble(site = factor(site_levels, levels = site_levels))
    dplyr::cross_join(sites, diameters) |>
      dplyr::arrange(site, diameter)
  } else {
    # Cross diameter only with the observed site:year combinations, as ordered
    # factors sorted by level, so the returned row order follows the fit's level
    # order rather than the (arbitrary) row order of fit$data.
    obs <- fit$data |>
      dplyr::distinct(site, year) |>
      dplyr::mutate(
        site = factor(as.character(site), levels = site_levels),
        year = factor(as.character(year), levels = fit$meta$year_levels)
      )
    dplyr::cross_join(obs, diameters) |>
      dplyr::arrange(site, year, diameter)
  }
}

# Draw fresh random effects for n new/unknown levels from their estimated
# distribution N(0, sd_rvar). Only the "sample" mode reaches here; the "average"
# mode leaves those rows at zero in the caller (no draw needed).
re_draw <- function(n, sd_rvar) {
  posterior::rvar_rng(stats::rnorm, n, mean = 0, sd = sd_rvar)
}

# Site intercept/slope per row: known rows take their estimated effect; unknown
# rows borrow the per-draw mean of the representative sites (rep_idx) if given,
# else follow new_levels.
resolve_re1 <- function(param, idx, new_levels, sd_rvar, rep_idx = NULL) {
  known <- !is.na(idx)
  if (all(known)) {
    return(rvar_index1(param, idx))
  }
  n <- length(idx)
  param_draws <- posterior::draws_of(param)
  ndraws <- nrow(param_draws)
  out <- matrix(0, nrow = ndraws, ncol = n)
  if (any(known)) {
    out[, known] <- param_draws[, idx[known], drop = FALSE]
  }
  if (!all(known)) {
    if (!is.null(rep_idx)) {
      out[, !known] <- rowMeans(param_draws[, rep_idx, drop = FALSE])
    } else if (new_levels == "sample") {
      out[, !known] <- posterior::draws_of(re_draw(sum(!known), sd_rvar))
    }
    # new_levels == "average" leaves unknown columns at zero.
  }
  posterior::rvar(out)
}

# site:year: conditioned only where both site and year are known, else new_levels.
resolve_re2 <- function(param, i, j, new_levels, sd_rvar) {
  known <- !is.na(i) & !is.na(j)
  n <- length(i)
  ndraws <- posterior::ndraws(param)
  out <- matrix(0, nrow = ndraws, ncol = n)
  if (any(known)) {
    param_draws <- posterior::draws_of(param)
    kk <- which(known)
    out[, kk] <- vapply(
      kk,
      function(r) param_draws[, i[r], j[r]],
      numeric(ndraws)
    )
  }
  if (!all(known) && new_levels == "sample") {
    out[, !known] <- posterior::draws_of(re_draw(sum(!known), sd_rvar))
  }
  posterior::rvar(out)
}

rvar_index1 <- function(rv, idx) {
  posterior::rvar(posterior::draws_of(rv)[, idx, drop = FALSE])
}
