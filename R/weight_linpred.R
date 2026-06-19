# Single source of truth (R side) for the weight-model mean. Returns the linear
# predictor on the log scale as a `posterior` rvar of length nrow(grid). Every
# downstream consumer (posterior_linpred/epred/predict, augment, kb_predict_weight,
# biomass) calls this, so the mean is never re-implemented. The Stan
# transformed-parameters block is the only other place the mean is defined.
#
# Conditioning is a property of the grid columns: a factor with a column present
# is conditioned on at its estimated random effects; a factor with no column is
# handled by `new_levels` ("sample" draws a new effect, "average" zeroes it).
.weight_linpred <- function(fit, grid, new_levels) {
  d <- fit$draws
  n <- nrow(grid)
  log_dc <- log(grid$diameter) - log(fit$meta$diameter_ref)
  site_obs <- "site" %in% names(grid)
  sy_obs <- all(c("site", "year") %in% names(grid))

  if (site_obs) {
    si <- match_levels(grid$site, fit$meta$site_levels, "site")
    re_site <- rvar_index1(d$bSite, si)
    re_slope <- rvar_index1(d$bSiteDiameter, si)
  } else {
    re_site <- re_draw(new_levels, n, d$sSite)
    re_slope <- re_draw(new_levels, n, d$sSiteDiameter)
  }
  if (sy_obs) {
    si <- match_levels(grid$site, fit$meta$site_levels, "site")
    yi <- match_levels(grid$year, fit$meta$year_levels, "year")
    re_sy <- rvar_index2(d$bSiteYear, si, yi)
  } else {
    re_sy <- re_draw(new_levels, n, d$sSiteYear)
  }

  d$bWeight30 + d$bDiameter * log_dc + d$bDiameter2 * log_dc^2 +
    re_site + re_slope * log_dc + re_sy
}

# Orchestrator for kb_predict_weight(): validate `by`, build the grid (expanding
# the named grouping factors over their observed levels), and compute the
# log-scale linear-predictor rvar. Returns the grid, the resolved `by`, and the
# linpred rvar. Conditioning then follows the grid columns inside
# .weight_linpred(), so `by` is purely the grid-construction control here.
weight_grid_linpred <- function(fit, new_data, by = NULL, new_levels) {
  .chk_kb_fit_weight(fit)
  new_levels <- rlang::arg_match(new_levels, c("sample", "average"))
  by <- validate_by_weight(by, new_levels)
  grid <- build_weight_grid(fit, new_data, by)
  list(
    grid = grid,
    by = by,
    linpred = .weight_linpred(fit, grid, new_levels)
  )
}

# For the posterior_* generics, a NULL `newdata` means the observed data (the
# ecosystem convention), unlike kb_predict_weight() where it means a diameter
# sequence.
predict_newdata <- function(object, newdata) {
  if (is.null(newdata)) tibble::as_tibble(object$data) else newdata
}

# Validate the `by` axis for the weight model. Returns a character vector.
validate_by_weight <- function(by, new_levels) {
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
  if (new_levels == "sample" && all(valid %in% by)) {
    cli::cli_abort(c(
      "{.code new_levels = \"sample\"} needs an omitted random-effect factor.",
      i = "{.code by = c(\"site\", \"year\")} conditions on every factor.",
      i = "Use {.code new_levels = \"average\"} instead."
    ))
  }
  by
}

# Build the prediction grid: a supplied new_data, or an auto-generated diameter
# sequence over the observed range crossed with the requested grouping levels.
build_weight_grid <- function(fit, new_data, by) {
  if (!is.null(new_data)) {
    if (!is.data.frame(new_data)) {
      cli::cli_abort("{.arg new_data} must be a data frame or {.code NULL}.")
    }
    if (!"diameter" %in% names(new_data)) {
      cli::cli_abort("{.arg new_data} must have a {.field diameter} column.")
    }
    return(tibble::as_tibble(new_data))
  }
  d_seq <- newdata::xnew_data(
    fit$data,
    newdata::xnew_seq(diameter, length_out = 30L)
  )$diameter
  if (length(by) == 0) {
    return(tibble::tibble(diameter = d_seq))
  }
  if (setequal(by, "site")) {
    g <- expand.grid(
      diameter = d_seq, site = fit$meta$site_levels,
      stringsAsFactors = FALSE
    )
  } else {
    obs <- unique(as.data.frame(fit$data)[c("site", "year")])
    obs[] <- lapply(obs, as.character)
    g <- merge(data.frame(diameter = d_seq), obs)
  }
  tibble::as_tibble(g)
}

re_draw <- function(new_levels, n, sd_rvar) {
  if (new_levels == "average") {
    return(0)
  }
  posterior::rvar_rng(stats::rnorm, n, mean = 0, sd = sd_rvar)
}

match_levels <- function(x, levels, nm) {
  idx <- match(as.character(x), levels)
  if (anyNA(idx)) {
    bad <- unique(as.character(x)[is.na(idx)])
    cli::cli_abort("Unknown {nm} level{?s} in {.arg new_data}: {.val {bad}}.")
  }
  idx
}

# index a length-m vector rvar by an integer vector -> rvar of that length
rvar_index1 <- function(rv, idx) {
  posterior::rvar(posterior::draws_of(rv)[, idx, drop = FALSE])
}

# index an [m x n] matrix rvar elementwise by (i, j) -> rvar of length(i)
rvar_index2 <- function(rv, i, j) {
  a <- posterior::draws_of(rv)
  out <- vapply(
    seq_along(i),
    function(r) a[, i[r], j[r]],
    numeric(dim(a)[1])
  )
  posterior::rvar(out)
}
