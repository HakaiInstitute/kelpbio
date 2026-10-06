#' Build New Data for Prediction
#'
#' Build a grid of rows to predict at: one row per fitted site, year, or
#' observed site-year, crossed for a weight fit with a sequence of the species
#' predictor.
#'
#' @details
#' Pass the result as `new_data` to the model's prediction function, for example
#' `kb_predict_size(fit, kb_new_data(fit, by = "site"))`. The grouping factors not
#' named in `by` are absent from the grid, so the prediction treats them as set
#' by `new_levels`: with the default `"average"`, the typical site or year.
#'
#' For a weight fit, supply the predictor values by the predictor's column name:
#' `diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*. A single value
#' gives one row per group at that size. Predictions over a grid with several
#' predictor values are drawn by [kb_plot_predictions()] as curves.
#'
#' `by = c("site", "year")` gives only the site-years in the fitted data. The
#' result is an ordinary data frame: rows can be filtered and columns added (such
#' as `stipes_m2` for a *Nereocystis* weight fit with density) before predicting.
#'
#' @inheritParams params
#' @param fit A `kb_fit_weight`, `kb_fit_size`, or `kb_fit_density` object.
#' @param ... For a weight fit, the predictor values as a named numeric vector
#'   (`diameter_mm` or `fronds`). If omitted, 30 evenly spaced values span the
#'   observed range.
#'
#' @return A tibble with the grouping columns named in `by` and, for a weight
#'   fit, the predictor column.
#' @family prediction
#' @export
#'
#' @examples
#' kb_new_data(fit_size_sim_nereo, by = "site")
#'
#' # Weight curves by site, and weight at 50 mm by site:
#' kb_new_data(fit_weight_sim_nereo, by = "site")
#' kb_new_data(fit_weight_sim_nereo, by = "site", diameter_mm = 50)
#'
#' kb_predict_size(fit_size_sim_nereo, kb_new_data(fit_size_sim_nereo, by = "site"))
kb_new_data <- function(fit, by = NULL, ...) {
  .chk_kb_fit_grouped(fit)
  by <- validate_by(fit, by)
  dots <- rlang::list2(...)
  .chk_grid_predictor(fit, dots)

  grid <- build_by_grid(fit, by, if (length(dots)) dots[[1]])
  # Marks a grid over the predictor, so its predictions are drawn as curves.
  attr(grid, "kb_curve") <- !is.null(fit$meta[["predictor"]])
  grid
}
