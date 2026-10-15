#' Predict Density
#'
#' Predict the expected density, stipes (*Nereocystis*) or plants
#' (*Macrocystis*) per m², at each row of `new_data`, or at the observed
#' transects when `new_data = NULL`.
#'
#' @details
#' An `area_m2` column is ignored; use [posterior_predict()] for counts on a
#' transect. For *Nereocystis*, the expected density includes unoccupied
#' transects.
#'
#' `new_data` needs no columns: each row is a site, a year, or a site-year, given
#' by its optional `site` and `year` columns.
#'
#' With `representative_site`, a new site also takes the named sites'
#' site:year effect in a year in which they were surveyed.
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
#' # At new rows, including a new site:
#' kb_predict_density(fit, data.frame(site = c("otter_cove", "new_site")))
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
  .chk_kb_fit(fit, "kb_fit_density")
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
