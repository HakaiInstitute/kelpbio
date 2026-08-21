#' Predict Weight Over a Predictor Sequence by Grouping Factor
#'
#' Summarise the fitted allometric relationship over a generated prediction grid:
#' a sequence of predictor values crossed with the grouping factors named in `by`
#' (one curve per group). The predictor sequence is supplied through the fit's
#' species predictor argument: `diameter` for a *Nereocystis* fit, `fronds` for a
#' *Macrocystis* fit (see the methods linked below).
#'
#' @details
#' `by` selects the grouping factors that each get their own curve, conditioned on
#' their estimated random effects. `new_levels` controls the factors not named in
#' `by`: the default `"average"` holds those random effects at zero (the
#' typical-group curve), while `"sample"` draws a new random effect from its
#' estimated distribution, widening the uncertainty to include between-group
#' variation. Set a seed with `set.seed()` for reproducible `"sample"` intervals.
#'
#' The available `by` values are `NULL` (a single population curve), `"site"`, and
#' `c("site", "year")` for both species; the *Macrocystis* model additionally
#' allows `"year"`, since it has a year main effect (the *Nereocystis* model does
#' not, so `by = "year"` errors there).
#'
#' @param fit A `kb_fit_weight` object.
#' @param ... Passed to the species method: the predictor sequence (`diameter` for
#'   *Nereocystis*, `fronds` for *Macrocystis*) and the shared summary arguments.
#'
#' @return A `kb_predictions` object: a summary tibble with `estimate`, `lower`,
#'   `upper`, the predictor column, and the `by` grouping columns.
#' @family prediction
#' @seealso [kb_predict_weight()] for predictions at the rows of a supplied data
#'   frame.
#' @export
#'
#' @examples
#' kb_predict_weight_by(fit_weight_sim_nereo, by = "site")
kb_predict_weight_by <- function(fit, ...) {
  UseMethod("kb_predict_weight_by")
}

#' @export
kb_predict_weight_by.default <- function(fit, ...) {
  .chk_kb_fit_weight(fit, call = rlang::current_env())
  .abort_no_method("kb_predict_weight_by", fit, call = rlang::current_env())
}

#' @describeIn kb_predict_weight_by *Nereocystis* method; predicts over a sub-bulb
#'   `diameter` sequence.
#' @inheritParams params
#' @param diameter A numeric vector of sub-bulb diameter values to predict over
#'   (in the units of the fitted data), or `NULL` for an automatic sequence
#'   spanning the observed range.
#' @export
kb_predict_weight_by.kb_fit_weight_nereo <- function(
  fit,
  by = NULL,
  diameter = NULL,
  ...,
  new_levels = c("average", "sample"),
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  .chk_wrong_predictor(fit, ...)
  rlang::check_dots_empty()
  .kb_predict_weight_by(
    fit,
    by,
    diameter,
    new_levels,
    conf_level,
    estimate,
    sig_fig
  )
}

#' @describeIn kb_predict_weight_by *Macrocystis* method; predicts over a
#'   `fronds` sequence.
#' @param fronds A numeric vector of frond-count values to predict over, or `NULL`
#'   for an automatic sequence spanning the observed range.
#' @export
kb_predict_weight_by.kb_fit_weight_macro <- function(
  fit,
  by = NULL,
  fronds = NULL,
  ...,
  new_levels = c("average", "sample"),
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  .chk_wrong_predictor(fit, ...)
  rlang::check_dots_empty()
  .kb_predict_weight_by(
    fit,
    by,
    fronds,
    new_levels,
    conf_level,
    estimate,
    sig_fig
  )
}

# Shared implementation for the species methods: the former single-function body,
# with the species predictor passed positionally as the grid sequence.
.kb_predict_weight_by <- function(
  fit,
  by,
  predictor_values,
  new_levels,
  conf_level,
  estimate,
  sig_fig
) {
  .chk_kb_fit_weight(fit)
  .chk_summary_args(conf_level, estimate, sig_fig)

  res <- weight_by_linpred(fit, by, new_levels, predictor_values)
  summarise_weight_predictions(
    res$grid,
    res$linpred,
    res$by,
    predictor = fit$meta$predictor %||% "diameter",
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    curve = TRUE
  )
}


weight_by_linpred <- function(fit, by, new_levels, predictor = NULL) {
  .chk_kb_fit_weight(fit)
  new_levels <- rlang::arg_match(new_levels, c("sample", "average"))
  by <- validate_by_weight(by, fit$meta$species)
  grid <- build_by_grid(fit, by, predictor)
  list(
    grid = grid,
    by = by,
    linpred = .linpred(fit, grid, new_levels)
  )
}

# Valid `by` groupings depend on the fitted random-effect structure. Both species
# allow NULL, "site", and c("site", "year"). Nereo has no year main effect, so
# "year" alone is rejected; macro has one, so "year" is allowed.
validate_by_weight <- function(by, species = "nereocystis") {
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
  if (species == "nereocystis" && "year" %in% by && !"site" %in% by) {
    cli::cli_abort(c(
      "{.code by = \"year\"} is not available for the Nereocystis weight model.",
      i = "Year enters only through the site:year interaction (no year main effect).",
      i = "Use {.code by = NULL}, {.val site}, or {.code c(\"site\", \"year\")}."
    ))
  }
  by
}

build_by_grid <- function(fit, by, values = NULL) {
  # Legacy fits (built before meta$predictor was recorded) default to diameter,
  # matching the site_year_on legacy handling.
  predictor <- fit$meta$predictor %||% "diameter"
  if (is.null(values)) {
    rng <- range(fit$data[[predictor]], na.rm = TRUE)
    values <- seq(rng[1], rng[2], length.out = 30L)
  } else {
    chk::chk_numeric(values)
  }
  preds <- tibble::tibble(x = values)
  names(preds) <- predictor
  if (length(by) == 0) {
    return(preds)
  }
  site_levels <- fit$meta$site_levels
  year_levels <- fit$meta$year_levels
  if (setequal(by, "site")) {
    sites <- tibble::tibble(site = factor(site_levels, levels = site_levels))
    dplyr::cross_join(sites, preds) |>
      dplyr::arrange(.data$site, .data[[predictor]])
  } else if (setequal(by, "year")) {
    years <- tibble::tibble(year = factor(year_levels, levels = year_levels))
    dplyr::cross_join(years, preds) |>
      dplyr::arrange(.data$year, .data[[predictor]])
  } else {
    # Cross the predictor only with the observed site:year combinations, as
    # ordered factors sorted by level, so the returned row order follows the
    # fit's level order rather than the (arbitrary) row order of fit$data.
    obs <- fit$data |>
      dplyr::distinct(.data$site, .data$year) |>
      dplyr::mutate(
        site = factor(as.character(.data$site), levels = site_levels),
        year = factor(as.character(.data$year), levels = year_levels)
      )
    dplyr::cross_join(obs, preds) |>
      dplyr::arrange(.data$site, .data$year, .data[[predictor]])
  }
}
