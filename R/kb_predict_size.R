#' Predict Size for New Data
#'
#' Predict the expected plant size for the supplied rows, or for the observed
#' data when `new_data = NULL`. For one estimate per site or year, use
#' [kb_predict_size_by()] instead.
#'
#' @details
#' The expected size is the mean of the fitted size distribution: maximum
#' sub-bulb diameter (mm) for *Nereocystis*, and the number of fronds reaching
#' 1 m above the holdfast for *Macrocystis*, among plants with at least one such
#' frond.
#'
#' The size models have no predictor, so `new_data` needs no columns: each row is
#' a site, a year, or a site-year, given by its optional `site` and `year`
#' columns. Conditioning is resolved per row: a `site`/`year` value the model has
#' seen is conditioned on its estimated random effects; a new site or year, or an
#' absent grouping column, is handled by `new_levels`.
#'
#' With the default `new_levels = "sample"`, an absent or new group draws a random
#' effect from its estimated distribution, so the interval includes between-group
#' variation; `"average"` instead holds those random effects at zero. `"sample"`
#' draws fresh values on each call; set a seed with `set.seed()` for a
#' reproducible interval.
#'
#' For a new site, `representative_site` instead borrows the site effect of one
#' or more named reference sites (the per-draw average across several). The
#' `site:year` interaction still follows `new_levels`.
#'
#' @inheritParams params
#' @param fit A `kb_fit_size` object.
#' @param new_data A data frame with optional `site` and `year` columns, one row
#'   per prediction, or `NULL` to predict at the observed data.
#'
#' @return A `kb_predictions` object: the input rows with added `estimate`,
#'   `lower`, and `upper` columns summarising the posterior distribution of
#'   expected size.
#' @family prediction
#' @seealso [kb_predict_size_by()] for one estimate per group, and
#'   [posterior_predict()] for draws of individual plant sizes.
#' @export
#'
#' @examples
#' kb_predict_size(
#'   fit_size_sim_nereo,
#'   data.frame(site = c("site1", "new_site")),
#'   new_levels = "average"
#' )
kb_predict_size <- function(fit, new_data = NULL, ...) {
  UseMethod("kb_predict_size")
}

#' @export
kb_predict_size.default <- function(fit, new_data = NULL, ...) {
  .chk_kb_fit_size(fit, call = rlang::current_env())
  .abort_no_method("kb_predict_size", fit, call = rlang::current_env())
}

#' @rdname kb_predict_size
#' @export
kb_predict_size.kb_fit_size <- function(
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
