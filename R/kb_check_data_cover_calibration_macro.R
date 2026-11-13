#' Check Macrocystis cover calibration data
#'
#' Check that `data` has the columns and values needed to fit the
#' *Macrocystis pyrifera* cover calibration model.
#'
#' @details
#' `data` is the output of [kb_predict_biomass_in_situ()] with its defaults, one
#' row per in situ survey.
#'
#' ```{r, echo = FALSE, results = "asis"}
#' cat(doc_data_columns("cover_calibration_macro"))
#' ```
#'
#' `plot_area_m2`, `canopy_area_m2`, and `canopy_tide_height_m` are given
#' together or missing together on each row. A row without them has no
#' canopy cover and is not fitted. Other columns are ignored.
#'
#' @inheritParams params
#' @param data A data frame of in situ survey biomass, one row per survey.
#'
#' @returns `data`, invisibly.
#' @family data checks
#' @export
#'
#' @examples
#' biomass <- kb_predict_biomass_in_situ(
#'   fit_weight_sim_macro,
#'   data_size_census_sim_macro,
#'   data_in_situ_sim_macro,
#'   progress = "none"
#' )
#' kb_check_data_cover_calibration_macro(biomass)
kb_check_data_cover_calibration_macro <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      chk::chk_string(x_name)
      .chk_cover_calibration_data(data, x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
