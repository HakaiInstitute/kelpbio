# Single source of truth (R side) for the weight-model mean: the log-scale linear
# predictor as a `posterior` rvar of length nrow(grid). Conditioning is resolved
# per row and per factor: known levels take their estimated random effect; new or
# absent levels are handled by `new_levels` ("sample" draws from Normal(0, sd),
# "average" holds at zero).
.weight_linpred <- function(fit, grid, new_levels) {
  d <- fit$draws
  n <- nrow(grid)
  log_dc <- log(grid$diameter_mm) - log(fit$meta$diameter_ref)

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

  re_site <- resolve_re1(d$bSite, si, new_levels, d$sSite)
  re_slope <- resolve_re1(d$bSiteDiameter, si, new_levels, d$sSiteDiameter)
  re_sy <- resolve_re2(d$bSiteYear, si, yi, new_levels, d$sSiteYear)

  d$bWeight30 + d$bDiameter * log_dc + d$bDiameter2 * log_dc^2 +
    re_site + re_slope * log_dc + re_sy
}

# Observed-data linear predictor (log scale), conditioned on each row's own site
# and year. The shared basis for fitted() and residuals(). new_levels is
# immaterial here: every observed row is a known level, conditioned regardless.
.weight_linpred_obs <- function(fit) {
  .weight_linpred(fit, tibble::as_tibble(fit$data), new_levels = "average")
}

# New-data verb (kb_predict_weight) and the posterior_* generics: predict at the
# supplied rows, or the observed data when new_data is NULL.
weight_data_linpred <- function(fit, new_data, new_levels) {
  .chk_kb_fit_weight(fit)
  new_levels <- rlang::arg_match(new_levels, c("sample", "average"))
  grid <- build_data_grid(fit, new_data)
  list(
    grid = grid,
    group_vars = intersect(c("site", "year"), names(grid)),
    linpred = .weight_linpred(fit, grid, new_levels)
  )
}

# Curve verb (kb_predict_weight_by): a diameter sequence crossed with the
# requested grouping levels, then predict.
weight_by_linpred <- function(fit, by, new_levels, diameter_mm = NULL) {
  .chk_kb_fit_weight(fit)
  new_levels <- rlang::arg_match(new_levels, c("sample", "average"))
  by <- validate_by_weight(by)
  grid <- build_by_grid(fit, by, diameter_mm)
  list(
    grid = grid,
    by = by,
    linpred = .weight_linpred(fit, grid, new_levels)
  )
}

# Validate the `by` axis for the weight model. Returns a character vector.
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
  if ("year" %in% by && !"site" %in% by) {
    cli::cli_abort(c(
      "{.code by = \"year\"} is not available for the weight model.",
      i = "Year enters only through the site:year interaction (no year main effect).",
      i = "Use {.code by = NULL}, {.val site}, or {.code c(\"site\", \"year\")}."
    ))
  }
  by
}

# New-data grid: the supplied rows (must carry a `diameter_mm` column), or the
# observed data when new_data is NULL.
build_data_grid <- function(fit, new_data) {
  if (is.null(new_data)) {
    return(tibble::as_tibble(fit$data))
  }
  if (!is.data.frame(new_data)) {
    cli::cli_abort("{.arg new_data} must be a data frame or {.code NULL}.")
  }
  if (!"diameter_mm" %in% names(new_data)) {
    cli::cli_abort("{.arg new_data} must have a {.field diameter_mm} column.")
  }
  tibble::as_tibble(new_data)
}

# Curve grid: a diameter sequence (auto over the observed range, or supplied)
# crossed with the levels of the grouping factors named in `by`.
build_by_grid <- function(fit, by, diameter_mm = NULL) {
  if (is.null(diameter_mm)) {
    rng <- range(fit$data$diameter_mm, na.rm = TRUE)
    diameter_mm <- seq(rng[1], rng[2], length.out = 30L)
  } else {
    chk::chk_numeric(diameter_mm)
  }
  if (length(by) == 0) {
    return(tibble::tibble(diameter_mm = diameter_mm))
  }
  if (setequal(by, "site")) {
    g <- expand.grid(
      diameter_mm = diameter_mm, site = fit$meta$site_levels,
      stringsAsFactors = FALSE
    )
  } else {
    obs <- unique(as.data.frame(fit$data)[c("site", "year")])
    obs[] <- lapply(obs, as.character)
    g <- merge(data.frame(diameter_mm = diameter_mm), obs)
  }
  tibble::as_tibble(g)
}

# Draw a length-n random-effect rvar from Normal(0, sd_rvar) ("sample"), or a
# scalar zero ("average"). Used for new/absent levels.
re_draw <- function(new_levels, n, sd_rvar) {
  if (new_levels == "average") {
    return(0)
  }
  posterior::rvar_rng(stats::rnorm, n, mean = 0, sd = sd_rvar)
}

# Resolve a vector-indexed random effect (site intercept or slope) to a length-n
# rvar. `idx` is match() output (NA = new or absent): known rows take the
# estimated effect, the rest are drawn per `new_levels`.
resolve_re1 <- function(param, idx, new_levels, sd_rvar) {
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
  if (any(!known) && new_levels == "sample") {
    out[, !known] <- posterior::draws_of(re_draw("sample", sum(!known), sd_rvar))
  }
  posterior::rvar(out)
}

# Resolve the site:year interaction to a length-n rvar. A row is conditioned
# only when both its site and year are known levels; otherwise it is drawn per
# `new_levels`.
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
