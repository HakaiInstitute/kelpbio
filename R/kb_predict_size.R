#' Predict size
#'
#' Predict the expected plant size at each row of `new_data`, or at the observed
#' data when `new_data = NULL`.
#'
#' @details
#' The expected size is the mean of the fitted size distribution: plant
#' diameter (mm) for *Nereocystis*, and the number of fronds reaching
#' 1 m above the holdfast for *Macrocystis*, among plants with at least one such
#' frond.
#'
#' The size models have no predictor, so `new_data` needs no columns: each row is
#' a site, a year, or a site-year, given by its optional `site` and `year`
#' columns.
#'
#' With `representative_site`, a new site also takes the named sites'
#' site:year effect in a year in which they have data.
#'
#' @inheritParams params
#' @param fit A `kb_fit_size` object.
#' @param new_data A data frame with optional `site` and `year` columns, one row
#'   per prediction, or `NULL` to predict at the observed data.
#'
#' @returns A `kb_predictions` object: the rows of `new_data` with added
#'   `estimate`, `lower`, and `upper` columns summarising the posterior
#'   distribution of expected size. When the rows have `site` and `year`, a
#'   `size_support` column (as in [kb_predict_mean_weight()]) precedes the
#'   summary.
#' @family prediction functions
#' @seealso [kb_new_data()] to build rows by site or year, and
#'   [posterior_predict()] for draws of individual plant sizes.
#' @export
#'
#' @examples
#' fit <- fit_size_sim_nereo
#'
#' # At the observed plants:
#' kb_predict_size(fit)
#'
#' # By site:
#' kb_predict_size(fit, kb_new_data(fit, by = "site"))
#'
#' # At new rows, including a new site:
#' kb_predict_size(fit, data.frame(site = c("otter_cove", "new_site")))
kb_predict_size <- function(
  fit,
  new_data = NULL,
  ...,
  new_levels = c("average", "sample"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  .chk_kb_fit(fit, "kb_fit_size")
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
