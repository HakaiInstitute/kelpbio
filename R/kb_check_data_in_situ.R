#' Check in situ survey data
#'
#' Check that `data` has the columns and values needed to predict the biomass
#' of in situ surveys with [kb_predict_biomass_in_situ()].
#'
#' @details
#' Each row of `data` is one survey: one count of the plants in a surveyed
#' area. A plant is one individual (sporophyte), identified by its holdfast.
#' Required columns:
#'
#' - `survey_id`, factor, character, or numeric, identifying each survey once.
#'   Surveys of the same site in the same year, including on the same day, are
#'   separate rows.
#' - `site`, factor or character, and `year`, factor, character, or whole
#'   numbers. A numeric `year` or `survey_id` is used as its character value.
#' - `survey_area_m2`, the surveyed area (m², > 0), such as a dive's transects.
#'   Biomass per m² is the biomass counted over this area.
#' - `plants`, the number of plants counted (`>= 0`), when sizes come from a
#'   size fit. It must be absent when `size_census` is given; the counts then
#'   come from its rows.
#'
#' A survey with canopy imagery also has `plot_area_m2` (the plot polygon,
#' m², > 0), over which the drone cover is measured, `canopy_area_m2` (the
#' canopy delineated within it, m², `>= 0` and at most `plot_area_m2`), and
#' `canopy_tide_height_m` (the tide height when the canopy was imaged, m, chart
#' datum). The three are given together or left missing together. When the
#' whole plot is surveyed, `survey_area_m2` equals `plot_area_m2`. Other
#' columns, such as `region`, are ignored, and can be named in `pool_by`.
#'
#' @inheritParams params
#' @param data A data frame of in situ surveys, one row per survey.
#' @param size_census A data frame of every plant the surveys counted, one row
#'   per plant (see [kb_check_data_size_census_nereo()] and
#'   [kb_check_data_size_census_macro()] for the columns), or `NULL` to check
#'   `data` alone with its `plants` column.
#'
#' @returns `data`, invisibly. Warns when a survey's `survey_area_m2` exceeds its
#'   `plot_area_m2`.
#' @family data checks
#' @export
#'
#' @examples
#' kb_check_data_in_situ(data_in_situ_sim_nereo)
#' kb_check_data_in_situ(data_in_situ_sim_macro, data_size_census_sim_macro)
kb_check_data_in_situ <- function(
  data,
  size_census = NULL,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  census_name <- chk::deparse_backtick_chk(substitute(size_census))
  .with_call(
    {
      chk::chk_string(x_name)
      .chk_survey_data(data, size_census, x_name, census_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
