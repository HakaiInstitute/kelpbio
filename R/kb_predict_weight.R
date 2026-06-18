#' Predict Allometric Weight
#'
#' Predict weight over a diameter sequence from a fitted weight model, computed
#' from the stored posterior draws with the `posterior` `rvar` engine (see
#' `docs/predictions.md`). `kb_predict_weight()` returns a summary; the
#' `_samples()` variant returns the full posterior draws attached to the grid as
#' an `.prediction` `rvar` column.
#'
#' `by` selects grouping factors that each get their own curve, held at their
#' observed estimated random effects. `uncertainty` controls factors not named
#' in `by`: `"marginal"` (a new, unobserved level: drawn from the estimated
#' hyperprior) or `"typical"` (the population-average: random effects zeroed).
#' For the weight model the available `by` values are `NULL`, `"site"`, and
#' `c("site", "year")`.
#'
#' @inheritParams params
#' @param fit A `kb_fit_weight` object.
#' @param new_data A data frame with a `diameter` column (and the `by` columns),
#'   or `NULL` to auto-generate a diameter sequence over the observed range.
#'
#' @return A `kb_predictions` object: a summary tibble (`estimate`, `lower`,
#'   `upper` plus grouping columns) from `kb_predict_weight()`, or the grid with
#'   a `.prediction` `rvar` column from `kb_predict_weight_samples()`.
#' @export
kb_predict_weight <- function(fit,
                              new_data = NULL,
                              by = NULL,
                              uncertainty = c("marginal", "typical"),
                              conf_level = 0.95,
                              estimate = stats::median,
                              sig_fig = 3) {
  chk::chk_number(conf_level)
  chk::chk_range(conf_level)
  chk::chk_function(estimate)
  chk::chk_whole_number(sig_fig)

  s <- kb_predict_weight_samples(
    fit,
    new_data = new_data, by = by, uncertainty = uncertainty
  )
  pred <- s$.prediction
  a <- (1 - conf_level) / 2

  out <- s
  out$.prediction <- NULL
  out$estimate <- signif(estimate(pred), sig_fig)
  out$lower <- signif(unname(posterior::quantile2(pred, a)), sig_fig)
  out$upper <- signif(unname(posterior::quantile2(pred, 1 - a)), sig_fig)

  new_kb_predictions(
    out,
    predictor = attr(s, "kb_predictor"),
    group_vars = attr(s, "kb_group_vars"),
    response = attr(s, "kb_response"),
    response_units = attr(s, "kb_response_units")
  )
}

#' @rdname kb_predict_weight
#' @export
kb_predict_weight_samples <- function(fit,
                                      new_data = NULL,
                                      by = NULL,
                                      uncertainty = c("marginal", "typical"),
                                      ...) {
  rlang::check_dots_empty()
  if (!inherits(fit, "kb_fit_weight")) {
    cli::cli_abort("{.arg fit} must be a {.cls kb_fit_weight} object.")
  }
  uncertainty <- rlang::arg_match(uncertainty)
  by <- validate_by_weight(by, uncertainty)
  grid <- build_weight_grid(fit, new_data, by)
  grid$.prediction <- weight_prediction_rvar(fit, grid, by, uncertainty)
  new_kb_predictions(
    grid,
    predictor = "diameter", group_vars = by,
    response = "weight", response_units = "kg"
  )
}

# ---- internals ------------------------------------------------------------ #

validate_by_weight <- function(by, uncertainty) {
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
  if (uncertainty == "marginal" && all(valid %in% by)) {
    cli::cli_abort(c(
      "{.code uncertainty = \"marginal\"} needs an omitted random-effect factor.",
      i = "{.code by = c(\"site\", \"year\")} conditions on every factor.",
      i = "Use {.code uncertainty = \"typical\"} instead."
    ))
  }
  by
}

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

weight_prediction_rvar <- function(fit, grid, by, uncertainty) {
  d <- fit$draws
  n <- nrow(grid)
  log_dc <- log(grid$diameter) - log(fit$meta$diameter_ref)
  site_obs <- "site" %in% by
  sy_obs <- ("site" %in% by) && ("year" %in% by)

  if (site_obs) {
    si <- match_levels(grid$site, fit$meta$site_levels, "site")
    re_site <- rvar_index1(d$bSite, si)
    re_slope <- rvar_index1(d$bSiteDiameter, si)
  } else {
    re_site <- re_draw(uncertainty, n, d$sSite)
    re_slope <- re_draw(uncertainty, n, d$sSiteDiameter)
  }
  if (sy_obs) {
    si <- match_levels(grid$site, fit$meta$site_levels, "site")
    yi <- match_levels(grid$year, fit$meta$year_levels, "year")
    re_sy <- rvar_index2(d$bSiteYear, si, yi)
  } else {
    re_sy <- re_draw(uncertainty, n, d$sSiteYear)
  }

  exp(
    d$bWeight30 + d$bDiameter * log_dc + d$bDiameter2 * log_dc^2 +
      re_site + re_slope * log_dc + re_sy
  )
}

re_draw <- function(uncertainty, n, sd_rvar) {
  if (uncertainty == "typical") {
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
