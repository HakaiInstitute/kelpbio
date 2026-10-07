#' Predict Weight
#'
#' Predict the expected wet weight (kg) of a plant at each row of `new_data`, or
#' at the observed data when `new_data = NULL`.
#'
#' @details
#' Each row is resolved on its own: a `site` or `year` the model has seen is
#' conditioned on its estimated effect, and a new or absent site or year follows
#' `new_levels`. With the default `"average"`, an unseen site is the typical
#' site; use `"sample"` for an interval that includes the variation between
#' sites. For a new site, `representative_site` instead borrows the site effect of
#' one or more named fitted sites (the per-draw average across several), while
#' the site:year interaction still follows `new_levels`.
#'
#' For curves by site or year, build the rows with [kb_new_data()].
#'
#' For a *Nereocystis* fit that includes density, each row uses its `stipes_m2`
#' value if present, otherwise the recorded density of its site-year in the
#' fitted data, otherwise the fitted mean density.
#'
#' @inheritParams params
#' @param fit A `kb_fit_weight` object.
#' @param new_data A data frame with the fit's predictor column (`diameter_mm` in
#'   millimetres for *Nereocystis*, `fronds` for *Macrocystis*) and optional
#'   `site` and `year` columns (and, for *Nereocystis*, an optional `stipes_m2`
#'   column in stipes per m²), or `NULL` to predict at the observed data.
#' @param ... Unused.
#'
#' @return A `kb_predictions` object: the rows of `new_data` with added
#'   `estimate`, `lower`, and `upper` columns summarising the posterior
#'   distribution of expected weight.
#' @family prediction
#' @seealso [kb_new_data()] to build rows by site or year over a predictor
#'   sequence, and [posterior_predict()] for draws of individual plant weights.
#' @export
#'
#' @examples
#' fit <- fit_weight_sim_nereo
#'
#' # At the observed plants:
#' kb_predict_weight(fit)
#'
#' # Curves by site:
#' kb_predict_weight(fit, kb_new_data(fit, by = "site"))
#'
#' # At your own measurements:
#' kb_predict_weight(fit, data.frame(diameter_mm = c(20, 40, 60)))
#'
#' # A new site, with between-site variation:
#' set.seed(1)
#' kb_predict_weight(
#'   fit,
#'   data.frame(diameter_mm = 40, site = "new_site"),
#'   new_levels = "sample"
#' )
kb_predict_weight <- function(
  fit,
  new_data = NULL,
  ...,
  new_levels = c("average", "sample"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  .chk_kb_fit(fit, "kb_fit_weight")
  rlang::check_dots_empty()
  predict_rows(
    fit,
    new_data,
    new_levels,
    representative_site,
    conf_level,
    estimate,
    sig_fig
  )
}
