#' Build New Data for Prediction
#'
#' Build a grid of rows to predict at: one row per fitted site, year, or
#' observed site-year, crossed for a weight or cover biomass fit with a sequence
#' of its predictor.
#'
#' @details
#' Pass the result as `new_data` to the model's prediction function, for example
#' `kb_predict_size(fit, kb_new_data(fit, by = "site"))`. The grouping factors not
#' named in `by` are absent from the grid, so the prediction treats them as set
#' by `new_levels`: with the default `"average"`, the typical site or year.
#'
#' For a weight fit, supply the predictor values by the predictor's column name:
#' `diameter_mm` for *Nereocystis*, `fronds` for *Macrocystis*. For a cover
#' biomass fit, supply `cover`, the tide-corrected proportion of the plot
#' covered by canopy (0 to 1); each row is then a unit plot at zero tide height,
#' with the `canopy_area_m2`, `plot_area_m2`, and `tide_height_m` columns the
#' prediction reads. A single value gives one row per group at that value.
#' Predictions over a grid with several predictor values are drawn by
#' [kb_plot_predictions()] as curves.
#'
#' `by = c("site", "year")` gives only the site-years in the fitted data. The
#' result is an ordinary data frame: rows can be filtered and columns added (such
#' as `stipes_m2` for a *Nereocystis* weight fit with density) before predicting.
#'
#' @inheritParams params
#' @param fit A `kb_fit_weight`, `kb_fit_size`, `kb_fit_density`, or
#'   `kb_fit_cover_biomass` object.
#' @param ... For a weight or cover biomass fit, the predictor values as a named
#'   numeric vector (`diameter_mm`, `fronds`, or `cover`). If omitted, 30 evenly
#'   spaced values span the observed range for weight, and 0 to 1 for cover.
#'
#' @return A tibble with the grouping columns named in `by`, the predictor
#'   column for a weight or cover biomass fit, and for a cover biomass fit the
#'   survey columns.
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

  grid <- .grid_columns(fit, build_by_grid(fit, by, if (length(dots)) dots[[1]]))
  # Marks a grid over the predictor, so its predictions are drawn as curves.
  attr(grid, "kb_curve") <- !is.null(fit$meta[["predictor"]])
  grid
}

# The columns a model's prediction reads, added to the grid: none for most
# models, the survey columns for a cover biomass fit.
.grid_columns <- function(fit, grid) {
  UseMethod(".grid_columns")
}

#' @export
.grid_columns.default <- function(fit, grid) {
  .abort_no_method(x = fit, call = NULL)
}

#' @export
.grid_columns.kb_fit_weight <- function(fit, grid) {
  grid
}

#' @export
.grid_columns.kb_fit_size <- function(fit, grid) {
  grid
}

#' @export
.grid_columns.kb_fit_density <- function(fit, grid) {
  grid
}

# Cover arrives tide-corrected: as the canopy of a unit plot at zero tide height,
# the correction and the cap leave it unchanged.
#' @export
.grid_columns.kb_fit_cover_biomass <- function(fit, grid) {
  chk::chk_not_any_na(grid$cover, x_name = "`cover`")
  chk::chk_range(grid$cover, x_name = "`cover`")
  grid$canopy_area_m2 <- grid$cover
  grid$plot_area_m2 <- 1
  grid$tide_height_m <- 0
  grid
}
