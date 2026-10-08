#' Build New Data for Prediction
#'
#' Build a grid of rows to predict at: one row per fitted site, year, or
#' observed site-year, or per supplied site or year, crossed for a weight or
#' cover biomass fit with a sequence of its predictor.
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
#' To fix a grouping factor at chosen levels, supply them by name in `...`, for
#' example `year = 2021` with `by = "site"` for every fitted site in 2021, or
#' `site = "otter_cove", year = 2019:2022`. Each value is crossed with the rest
#' of the grid. A level the fit has not seen, such as a future year, is a new
#' level, resolved at prediction by `new_levels`.
#'
#' `by = c("site", "year")` gives only the site-years in the fitted data. The
#' result is an ordinary data frame: rows can be filtered and columns added (such
#' as `stipes_m2` for a *Nereocystis* weight fit with density) before predicting.
#'
#' @inheritParams params
#' @param fit A `kb_fit_weight`, `kb_fit_size`, `kb_fit_density`, or
#'   `kb_fit_cover_biomass` object.
#' @param ... Named values to cross into the grid: for a weight or cover biomass
#'   fit, the predictor values as a numeric vector (`diameter_mm`, `fronds`, or
#'   `cover`); and the levels of `site` or `year` not named in `by`. If the
#'   predictor is omitted, 30 evenly spaced values span the observed range for
#'   weight (whole numbers for `fronds`), and 0 to 1 for cover.
#'
#' @return A tibble with the grouping columns named in `by` or `...`, the predictor
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
#' # Every site in 2021, and one site across years:
#' kb_new_data(fit_weight_sim_nereo, by = "site", diameter_mm = 50, year = 2021)
#' kb_new_data(fit_size_sim_nereo, site = "otter_cove", year = 2019:2022)
#'
#' kb_predict_size(fit_size_sim_nereo, kb_new_data(fit_size_sim_nereo, by = "site"))
kb_new_data <- function(fit, by = NULL, ...) {
  .chk_kb_fit_grouped(fit)
  by <- validate_by(by)
  dots <- rlang::list2(...)
  .with_call(.chk_grid_dots(fit, dots, by), rlang::current_env())

  predictor <- fit$meta[["predictor"]]
  values <- if (!is.null(predictor)) dots[[predictor]]
  grid <- build_by_grid(fit, by, values)
  for (group in intersect(.group_vars(), names(dots))) {
    fixed <- tibble::tibble(value = as.character(dots[[group]]))
    names(fixed) <- group
    grid <- dplyr::cross_join(grid, fixed)
  }
  grid <- dplyr::relocate(grid, dplyr::any_of(.group_vars()))
  grid <- .grid_columns(fit, grid)
  attr(grid, "kb_curve") <- !is.null(predictor)
  grid
}

# Adds the columns a model's prediction reads beyond `by` and the predictor.
.grid_columns <- function(fit, grid) {
  UseMethod(".grid_columns")
}

#' @export
.grid_columns.default <- function(fit, grid) {
  .abort_no_method(fit, call = NULL)
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

# Cover is already tide-corrected: on a unit plot at zero tide height the
# correction and the cap leave it unchanged.
#' @export
.grid_columns.kb_fit_cover_biomass <- function(fit, grid) {
  chk::chk_not_any_na(grid$cover, x_name = "`cover`")
  chk::chk_range(grid$cover, x_name = "`cover`")
  grid$canopy_area_m2 <- grid$cover
  grid$plot_area_m2 <- 1
  grid$tide_height_m <- 0
  grid
}
