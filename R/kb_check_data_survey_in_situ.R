#' Check in situ survey data
#'
#' Check that `data` has the columns and values needed to predict the biomass
#' of in situ surveys with [kb_predict_biomass_in_situ()].
#'
#' @details
#' Each row is one survey, with a count of the plants in the surveyed area. A
#' survey is the area over which canopy percent cover is calculated, and can
#' combine several transects.
#'
#' ```{r, echo = FALSE, results = "asis"}
#' cat(doc_data_columns("survey_in_situ"))
#' ```
#'
#' `plants` is required when only a sample of plants is measured (a size
#' sample), and must be absent when every plant is measured (a size census),
#' since the count then comes from the census rows. The plot cover columns
#' (`plot_area_m2`, `canopy_area_m2`, and `canopy_tide_height_m`) are either
#' all present or all missing on each row. Other grouping columns, such as
#' `region`, can be named in `pool_by`.
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
#' kb_check_data_survey_in_situ(data_survey_in_situ_sim_nereo)
#' kb_check_data_survey_in_situ(data_survey_in_situ_sim_macro, data_size_census_sim_macro)
kb_check_data_survey_in_situ <- function(
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
