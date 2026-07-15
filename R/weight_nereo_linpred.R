# Single R-side source of the Nereocystis weight-model mean (log scale), as a
# posterior rvar over grid rows. All predict paths route through here.
.weight_nereo_linpred <- function(fit, grid, new_levels, representative_site = NULL) {
  d <- fit$draws
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

  re_site <- resolve_re1(d$bSite, si, new_levels, d$sSite, rep_idx)
  re_slope <- resolve_re1(d$bSiteDiameter, si, new_levels, d$sSiteDiameter, rep_idx)
  # When the fit omitted the site:year effect its draws are prior-only noise, so
  # predictions must add nothing rather than reintroduce spurious variation. A
  # missing flag (fits built before it was recorded) defaults to on, since those
  # fits always included the effect; only an explicit FALSE disables it.
  re_sy <- if (isFALSE(fit$meta$site_year_on)) {
    0
  } else {
    resolve_re2(d$bSiteYear, si, yi, new_levels, d$sSiteYear)
  }

  d$bWeight + d$bDiameter * log_dc + d$bDiameter2 * log_dc^2 +
    re_site + re_slope * log_dc + re_sy
}

# new_levels is immaterial: every observed row is a known level.
.weight_nereo_linpred_obs <- function(fit) {
  .weight_nereo_linpred(fit, tibble::as_tibble(fit$data), new_levels = "average")
}

weight_data_linpred <- function(fit, new_data, new_levels, representative_site = NULL) {
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
  if (is.null(by)) by <- character(0)
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
  if (setequal(by, "site")) {
    g <- expand.grid(
      diameter = diameter, site = fit$meta$site_levels,
      stringsAsFactors = FALSE
    )
  } else {
    # Cross diameter only with site:year combinations that were observed.
    obs <- unique(as.data.frame(fit$data)[c("site", "year")])
    obs[] <- lapply(obs, as.character)
    g <- merge(data.frame(diameter = diameter), obs)
  }
  tibble::as_tibble(g)
}

re_draw <- function(new_levels, n, sd_rvar) {
  if (new_levels == "average") {
    return(0)
  }
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
  ndraws <- posterior::ndraws(param)
  out <- matrix(0, nrow = ndraws, ncol = n)
  if (any(known)) {
    out[, known] <- posterior::draws_of(param)[, idx[known], drop = FALSE]
  }
  if (any(!known)) {
    if (!is.null(rep_idx)) {
      out[, !known] <- rowMeans(posterior::draws_of(param)[, rep_idx, drop = FALSE])
    } else if (new_levels == "sample") {
      out[, !known] <- posterior::draws_of(re_draw("sample", sum(!known), sd_rvar))
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
    a <- posterior::draws_of(param)
    kk <- which(known)
    out[, kk] <- vapply(kk, function(r) a[, i[r], j[r]], numeric(ndraws))
  }
  if (any(!known) && new_levels == "sample") {
    out[, !known] <- posterior::draws_of(re_draw("sample", sum(!known), sd_rvar))
  }
  posterior::rvar(out)
}

rvar_index1 <- function(rv, idx) {
  posterior::rvar(posterior::draws_of(rv)[, idx, drop = FALSE])
}
