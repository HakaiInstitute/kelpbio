#' Predict Weight for New Data
#'
#' Predict weight at the rows you supply: a data frame of measured diameters and,
#' optionally, the site and year they were collected at. With `new_data = NULL`
#' it predicts at the observed data. For allometric curves over a diameter
#' sequence, use [kb_predict_weight_by()].
#'
#' @details
#' Conditioning is resolved per row: a `site`/`year` value the model has seen is
#' conditioned on its estimated random effects; a new site or year, or an absent
#' grouping column, is handled by `new_levels`. A mix of observed and new sites in
#' one `new_data` is resolved row by row, in a single call.
#'
#' @inheritParams params
#' @param fit A `kb_fit_weight` object.
#' @param new_data A data frame with a `diameter_mm` column (and optional `site`
#'   / `year` columns), or `NULL` to predict at the observed data.
#'
#' @return A `kb_predictions` object: the input rows with added `estimate`,
#'   `lower`, and `upper` columns.
#' @family prediction
#' @seealso [kb_predict_weight_by()] for curves, and [augment()] for fitted
#'   values at the observed data.
#' @export
#'
#' @examples
#' new_data <- data.frame(diameter_mm = c(20, 40, 60))
#' kb_predict_weight(fit_weight, new_data, new_levels = "average")
kb_predict_weight <- function(fit,
                              new_data = NULL,
                              new_levels = c("sample", "average"),
                              conf_level = 0.95,
                              estimate = stats::median,
                              sig_fig = 3) {
  .chk_kb_fit_weight(fit)
  chk::chk_number(conf_level)
  chk::chk_range(conf_level)
  chk::chk_function(estimate)
  chk::chk_whole_number(sig_fig)
  chk::chk_gt(sig_fig, value = 0)

  res <- weight_data_linpred(fit, new_data, new_levels)
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
    predictor = "diameter_mm", group_vars = group_vars,
    response = "weight_kg", response_units = "kg", predictor_units = "mm"
  )
}
