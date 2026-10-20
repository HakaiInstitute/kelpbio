#' Check in situ survey data
#'
#' Check that `data` has the columns and values needed to predict the biomass
#' of in situ surveys with [kb_predict_biomass_survey()].
#'
#' @details
#' Each row of `data` is one survey of a plot: one count of its plants on a
#' date. A plant is one individual (sporophyte), identified by its holdfast.
#' Required columns:
#'
#' - `site` and `plot_id`, factor or character, identifying the plot within its
#'   site.
#' - `date`, a `Date`. The year of the survey is the year of `date`; a `year`
#'   column, if present, must agree with it.
#' - `survey_area_m2`, the surveyed area (m², > 0), such as a dive's transects.
#'   Biomass per m² is the biomass counted over this area.
#' - `plants`, the number of plants counted (`>= 0`), when sizes come from a
#'   size fit. It must be absent when the `plants` argument is given; the
#'   counts then come from its rows.
#'
#' A survey paired with a drone flight also has `plot_area_m2` (the plot
#' polygon, m², > 0), over which the drone cover is measured, `canopy_area_m2`
#' (the canopy delineated within it, m², `>= 0` and at most `plot_area_m2`), and
#' `tide_height_m` (the tide height at the flight, m, chart datum). The three are
#' given together or left missing together. When the whole plot is surveyed,
#' `survey_area_m2` equals `plot_area_m2`. Each combination of `site`,
#' `plot_id`, and `date` appears once. Other columns are ignored.
#'
#' @inheritParams params
#' @param data A data frame of in situ surveys, one row per survey of a plot.
#' @param plants A data frame of counted plants, one row per plant (see
#'   [kb_check_data_plants_nereo()] and [kb_check_data_plants_macro()] for the
#'   columns), or `NULL` to check `data` alone with its `plants` column.
#'
#' @returns `data`, invisibly. Warns when a survey's `survey_area_m2` exceeds its
#'   `plot_area_m2`.
#' @family data checks
#' @export
#'
#' @examples
#' kb_check_data_survey(data_survey_sim_nereo)
#' kb_check_data_survey(data_survey_sim_macro, data_plants_sim_macro)
kb_check_data_survey <- function(
  data,
  plants = NULL,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  plants_name <- chk::deparse_backtick_chk(substitute(plants))
  .with_call(
    {
      chk::chk_string(x_name)
      .chk_survey_data(data, plants, x_name, plants_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
