#' Check canopy map data
#'
#' Check that `data` has the columns and values needed to predict canopy
#' biomass with [kb_predict_biomass_canopy()], which applies the same check to
#' its `new_data`.
#'
#' @details
#' Each row is one canopy map of a site; a site-year may have several.
#'
#' ```{r, echo = FALSE, results = "asis"}
#' cat(doc_data_columns("survey_canopy"))
#' ```
#'
#' Other grouping columns, such as `region`, can be named in `pool_by`.
#'
#' @inheritParams params
#' @param data A data frame of canopy maps, one row per map.
#'
#' @returns `data`, invisibly.
#' @family data checks
#' @export
#'
#' @examples
#' kb_check_data_survey_canopy(data_survey_canopy_sim_nereo)
kb_check_data_survey_canopy <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      chk::chk_string(x_name)
      .chk_canopy_maps(data, x_name)
      warn_implausible_units(data, x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
