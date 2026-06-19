# Single source of truth (R side) for the weight-model mean. Returns the linear
# predictor on the log scale as a `posterior` rvar of length nrow(grid). Every
# downstream consumer (posterior_linpred/epred/predict, augment, kb_predict_weight,
# kb_predict_weight_by, biomass) calls this, so the mean is never re-implemented.
# The Stan transformed-parameters block is the only other place the mean is defined.
#
# Conditioning is resolved per row, per factor: a row whose grouping level is
# known (seen in the fit) is conditioned on its estimated random effect; a row
# whose level is new, or whose grouping column is absent from the grid, is
# handled by `new_levels` ("sample" draws a fresh effect from Normal(0, sd),
# "average" holds it at zero). Known levels condition regardless of `new_levels`.
.weight_linpred <- function(fit, grid, new_levels) {
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

  re_site <- resolve_re1(d$bSite, si, new_levels, d$sSite)
  re_slope <- resolve_re1(d$bSiteDiameter, si, new_levels, d$sSiteDiameter)
  re_sy <- resolve_re2(d$bSiteYear, si, yi, new_levels, d$sSiteYear)

  d$bWeight30 + d$bDiameter * log_dc + d$bDiameter2 * log_dc^2 +
    re_site + re_slope * log_dc + re_sy
}

# Orchestrator for the new-data verb (kb_predict_weight) and the posterior_*
# generics: predict at the supplied rows, or at the observed data when
# new_data is NULL. Conditioning follows the grid's grouping columns and their
# level membership inside .weight_linpred().
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

# Orchestrator for the curve/summary verb (kb_predict_weight_by): build a
# diameter sequence crossed with the requested grouping levels, then predict.
weight_by_linpred <- function(fit, by, new_levels, diameter = NULL) {
  .chk_kb_fit_weight(fit)
  new_levels <- rlang::arg_match(new_levels, c("sample", "average"))
  by <- validate_by_weight(by)
  grid <- build_by_grid(fit, by, diameter)
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

# New-data grid: the supplied rows (must carry a `diameter` column), or the
# observed data when new_data is NULL (ecosystem convention; matches base R
# predict()).
build_data_grid <- function(fit, new_data) {
  if (is.null(new_data)) {
    return(tibble::as_tibble(fit$data))
  }
  if (!is.data.frame(new_data)) {
    cli::cli_abort("{.arg new_data} must be a data frame or {.code NULL}.")
  }
  if (!"diameter" %in% names(new_data)) {
    cli::cli_abort("{.arg new_data} must have a {.field diameter} column.")
  }
  tibble::as_tibble(new_data)
}

# Curve grid: a diameter sequence (auto over the observed range, or supplied)
# crossed with the levels of the grouping factors named in `by`.
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
    obs <- unique(as.data.frame(fit$data)[c("site", "year")])
    obs[] <- lapply(obs, as.character)
    g <- merge(data.frame(diameter = diameter), obs)
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
# rvar. `idx` is match() output against the estimated levels (NA = new or
# absent). Known rows take the estimated effect; the rest are drawn per
# `new_levels`.
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

# index a length-m vector rvar by an integer vector -> rvar of that length
rvar_index1 <- function(rv, idx) {
  posterior::rvar(posterior::draws_of(rv)[, idx, drop = FALSE])
}
