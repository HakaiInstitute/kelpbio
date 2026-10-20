#' Check Macrocystis cover calibration data
#'
#' Check that `data` has the columns and values needed to fit the
#' *Macrocystis pyrifera* cover calibration model.
#'
#' @details
#' `data` is the output of [kb_predict_biomass_survey()] with its defaults, one
#' row per in situ survey. Required columns:
#'
#' - `biomass_kg_m2`, the draws of the survey's wet biomass per m² (finite,
#'   `>= 0`).
#' - `site` and `year`, factor or character.
#' - `plot_area_m2` (the plot polygon, m², > 0), `canopy_area_m2` (the drone
#'   canopy delineated within it, m², `>= 0` and at most `plot_area_m2`), and
#'   `tide_height_m` (the tide height at the flight, m, chart datum), given
#'   together or missing together on each row. A row without them has no drone
#'   cover and is not fitted.
#'
#' Other columns are ignored.
#'
#' @inheritParams params
#' @param data A data frame of in situ survey biomass, one row per survey.
#'
#' @returns `data`, invisibly.
#' @family data checks
#' @export
#'
#' @examples
#' biomass <- kb_predict_biomass_survey(
#'   fit_weight_sim_macro,
#'   data_plants_sim_macro,
#'   data_survey_sim_macro,
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
