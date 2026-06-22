#' Predict Weight for New Data
#'
#' Predict weight for the supplied rows, or for the observed data when
#' `new_data = NULL`. For an allometric curve over a diameter sequence, use
#' [kb_predict_weight_by()] instead.
#'
#' @details
#' Conditioning is resolved per row: a `site`/`year` value the model has seen is
#' conditioned on its estimated random effects; a new site or year, or an absent
#' grouping column, is handled by `new_levels`. A mix of observed and new sites in
#' one `new_data` is resolved row by row, in a single call.
#'
#' For a new site, `representative_site` offers a third treatment: instead of
#' `new_levels` (`"sample"` or `"average"`) it borrows the site intercept and
#' slope of one or more named reference sites (the per-draw average across
#' several). The `site:year` interaction still follows `new_levels`. Because the
#' borrowed effects use the reference site's posterior, the interval is narrower
#' than a calibrated interval for a genuinely new site.
#'
#' @inheritParams params
#' @param fit A `kb_fit_weight` object.
#' @param new_data A data frame with a `diameter` column (and optional `site` /
#'   `year` columns), or `NULL` to predict at the observed data.
#'
#' @return A `kb_predictions` object: the input rows with added `estimate`,
#'   `lower`, and `upper` columns.
#' @family prediction
#' @seealso [kb_predict_weight_by()] for curves, and [augment()] for fitted
#'   values at the observed data.
#' @export
#'
#' @examples
#' new_data <- data.frame(diameter = c(20, 40, 60))
#' kb_predict_weight(fit_weight_hakai_nereo, new_data, new_levels = "average")
#'
#' # Predict a new site as if it behaves like a known reference site:
#' new_site <- data.frame(diameter = c(20, 40, 60), site = "new_site")
#' kb_predict_weight(
#'   fit_weight_hakai_nereo, new_site,
#'   representative_site = fit_weight_hakai_nereo$meta$site_levels[1]
#' )
kb_predict_weight <- function(fit,
                              new_data = NULL,
                              new_levels = c("sample", "average"),
                              representative_site = NULL,
                              conf_level = 0.95,
                              estimate = stats::median,
                              sig_fig = 3) {
  .chk_kb_fit_weight(fit)
  .chk_representative_site(fit, representative_site)
  chk::chk_number(conf_level)
  chk::chk_range(conf_level)
  chk::chk_function(estimate)
  chk::chk_whole_number(sig_fig)
  chk::chk_gt(sig_fig, value = 0)

  res <- weight_data_linpred(fit, new_data, new_levels, representative_site)
  summarise_weight_predictions(
    res$grid, res$linpred, res$group_vars,
    conf_level = conf_level, estimate = estimate, sig_fig = sig_fig
  )
}

# Shared summariser over a log-scale linpred rvar: exponentiate, reduce to
# estimate/lower/upper, attach kb_predictions metadata. Used by both prediction
# verbs so the summary is defined once.
summarise_weight_predictions <- function(grid, linpred, group_vars,
                                          conf_level, estimate, sig_fig) {
  epred <- exp(linpred)
  a <- (1 - conf_level) / 2

  out <- grid
  out$estimate <- signif(estimate(epred), sig_fig)
  out$lower <- signif(unname(posterior::quantile2(epred, a)), sig_fig)
  out$upper <- signif(unname(posterior::quantile2(epred, 1 - a)), sig_fig)

  new_kb_predictions(
    out,
    predictor = "diameter", group_vars = group_vars,
    response = "weight"
  )
}
