#' Predict Allometric Weight
#'
#' Predict weight over a diameter sequence from a fitted weight model. The
#' summary is the summariser over `posterior_epred()` (the prediction engine).
#' For the raw posterior prediction draws use `posterior_epred()` /
#' `posterior_predict()` directly.
#'
#' `by` builds a separate curve per observed level of each named grouping
#' factor, conditioned on that level's estimated random effects. `new_levels`
#' controls factors not named in `by`: `"sample"` (a new, unsampled group: a
#' random effect drawn from `Normal(0, sd)`) or `"average"` (the random effects
#' held at their central, zero, value). For the weight model the available `by`
#' values are `NULL`, `"site"`, and `c("site", "year")`.
#'
#' @inheritParams params
#' @param fit A `kb_fit_weight` object.
#' @param new_data A data frame with a `diameter` column (and the `by` columns),
#'   or `NULL` to auto-generate a diameter sequence over the observed range.
#'
#' @return A `kb_predictions` object: a summary tibble with `estimate`, `lower`,
#'   `upper` plus the grouping columns.
#' @family prediction
#' @export
kb_predict_weight <- function(fit,
                              new_data = NULL,
                              by = NULL,
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

  res <- weight_grid_linpred(fit, new_data, by, new_levels)
  epred <- exp(res$linpred)
  a <- (1 - conf_level) / 2

  out <- res$grid
  out$estimate <- signif(estimate(epred), sig_fig)
  out$lower <- signif(unname(posterior::quantile2(epred, a)), sig_fig)
  out$upper <- signif(unname(posterior::quantile2(epred, 1 - a)), sig_fig)

  new_kb_predictions(
    out,
    predictor = "diameter", group_vars = res$by,
    response = "weight", response_units = "kg"
  )
}
