#' Predict Density
#'
#' Predict the expected density, stipes (*Nereocystis*) or plants
#' (*Macrocystis*) per m², at each row of `new_data`, or at the observed
#' transects when `new_data = NULL`.
#'
#' @details
#' The estimate is always per m²: an `area_m2` column is not used. The expected
#' count on a transect is the density times its area, and so are its limits. For
#' draws of transect counts, use [posterior_predict()] with an `area_m2` column.
#' For *Nereocystis*, the expected density includes the probability that a
#' transect holds no stipes.
#'
#' `new_data` needs no columns: each row is a site, a year, or a site-year, given
#' by its optional `site` and `year` columns. For one row per site or year, build
#' the rows with [kb_new_data()].
#'
#' Each row is resolved on its own: a `site` or `year` the model has seen is
#' conditioned on its estimated effect, and a new or absent site or year follows
#' `new_levels`. With the default `"average"`, an unseen site is the typical
#' site; use `"sample"` for an interval that includes the variation between
#' sites. For a new site, `representative_site` instead borrows the site effect of
#' one or more named fitted sites (the per-draw average across several), while
#' the site:year interaction still follows `new_levels`.
#'
#' @inheritParams params
#' @param fit A `kb_fit_density` object.
#' @param new_data A data frame with optional `site` and `year` columns, one row
#'   per prediction, or `NULL` to predict at the observed transects.
#' @param ... Unused.
#'
#' @return A `kb_predictions` object: the rows of `new_data` with added
#'   `estimate`, `lower`, and `upper` columns summarising the posterior
#'   distribution of expected density per m².
#' @family prediction
#' @seealso [kb_new_data()] to build rows by site or year, and
#'   [posterior_predict()] for draws of transect counts.
#' @export
#'
#' @examples
#' fit <- fit_density_sim_nereo
#'
#' # At the observed transects:
#' kb_predict_density(fit)
#'
#' # By site:
#' kb_predict_density(fit, kb_new_data(fit, by = "site"))
#'
#' # At your own rows, including a new site:
#' kb_predict_density(fit, data.frame(site = c("site1", "new_site")))
kb_predict_density <- function(
  fit,
  new_data = NULL,
  ...,
  new_levels = c("average", "sample"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  .chk_kb_fit_density(fit)
  .chk_by_habit(new_data, ..., verb = "kb_predict_density")
  rlang::check_dots_empty()
  predict_rows(
    fit,
    new_data,
    new_levels,
    representative_site,
    conf_level,
    estimate,
    sig_fig,
    offset = FALSE,
    response = paste0(fit$meta$response, "_m2")
  )
}
