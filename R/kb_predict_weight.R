#' Predict Weight for New Data
#'
#' Predict weight for the supplied rows, or for the observed data when
#' `new_data = NULL`. For an allometric curve over a predictor sequence, use
#' [kb_predict_weight_by()] instead.
#'
#' @details
#' Conditioning is resolved per row: a `site`/`year` value the model has seen is
#' conditioned on its estimated random effects; a new site or year, or an absent
#' grouping column, is handled by `new_levels`.
#'
#' With the default `new_levels = "sample"`, an absent or new group draws a random
#' effect from its estimated distribution, so the interval includes between-group
#' variation; `"average"` instead holds those random effects at zero. `"sample"`
#' draws fresh values on each call; set a seed with `set.seed()` for a
#' reproducible interval. `"sample"` is the default because it produces honest
#' uncertainty for a new, unobserved site/year.
#'
#' For a new site, `representative_site` offers a third approach: instead of
#' `new_levels` (`"sample"` or `"average"`) it borrows the site intercept and
#' slope of one or more named reference sites (the per-draw average across
#' several). The `site:year` interaction still follows `new_levels`.
#'
#' @param fit A `kb_fit_weight` object.
#' @param ... Passed to the species method (currently only the shared arguments).
#'
#' @return A `kb_predictions` object: the input rows with added `estimate`,
#'   `lower`, and `upper` columns.
#' @family prediction
#' @seealso [kb_predict_weight_by()] to generate new_data by grouping factors and
#' a predictor sequence, and [augment()] for fitted/residual values at the
#' observed data.
#' @export
#'
#' @examples
#' new_data <- data.frame(diameter = c(20, 40, 60))
#' kb_predict_weight(fit_weight_sim_nereo, new_data, new_levels = "average")
#'
#' # Predict a new site as if it behaves like a known reference site:
#' new_site <- data.frame(diameter = c(20, 40, 60), site = "new_site")
#' kb_predict_weight(
#'   fit_weight_sim_nereo, new_site,
#'   representative_site = fit_weight_sim_nereo$meta$site_levels[1]
#' )
kb_predict_weight <- function(fit, ...) {
  UseMethod("kb_predict_weight")
}

#' @export
kb_predict_weight.default <- function(fit, ...) {
  .chk_kb_fit_weight(fit, call = rlang::current_env())
  .abort_no_method("kb_predict_weight", fit, call = rlang::current_env())
}

#' @describeIn kb_predict_weight *Nereocystis* method; `new_data` needs a
#'   `diameter` column.
#' @inheritParams params
#' @param new_data A data frame with the fit's predictor column (`diameter` for
#'   *Nereocystis*, `fronds` for *Macrocystis*) and optional `site` / `year`
#'   columns, or `NULL` to predict at the observed data.
#' @export
kb_predict_weight.kb_fit_weight_nereo <- function(
  fit,
  new_data = NULL,
  ...,
  new_levels = c("sample", "average"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  rlang::check_dots_empty()
  .kb_predict_weight(
    fit,
    new_data,
    new_levels,
    representative_site,
    conf_level,
    estimate,
    sig_fig
  )
}

#' @describeIn kb_predict_weight *Macrocystis* method; `new_data` needs a
#'   `fronds` column.
#' @export
kb_predict_weight.kb_fit_weight_macro <- function(
  fit,
  new_data = NULL,
  ...,
  new_levels = c("sample", "average"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  rlang::check_dots_empty()
  .kb_predict_weight(
    fit,
    new_data,
    new_levels,
    representative_site,
    conf_level,
    estimate,
    sig_fig
  )
}

# Shared implementation for the species methods (the former single-function body).
.kb_predict_weight <- function(
  fit,
  new_data,
  new_levels,
  representative_site,
  conf_level,
  estimate,
  sig_fig
) {
  .chk_kb_fit_weight(fit)
  .chk_representative_site(fit, representative_site)
  .chk_summary_args(conf_level, estimate, sig_fig)

  res <- data_linpred(fit, new_data, new_levels, representative_site)
  summarise_predictions(
    fit,
    res$grid,
    res$linpred,
    res$group_vars,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    curve = FALSE
  )
}
