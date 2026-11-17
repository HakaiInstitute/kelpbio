#' Check canopy map data
#'
#' Check that `data` has the columns and values needed to predict canopy
#' biomass with [kb_predict_biomass_canopy()], which applies the same check to
#' its `new_data`.
#'
#' @details
#' Each row of `data` is one map of a site's canopy. A site-year may have
#' several maps, such as from imagery weeks apart.
#'
#' ```{r, echo = FALSE, results = "asis"}
#' cat(doc_data_columns("canopy"))
#' ```
#'
#' Required columns have no missing values. Other columns, such as `region`,
#' are ignored, and can be named in `pool_by`.
#'
#' @inheritParams params
#' @param data A data frame of canopy maps, one row per map.
#'
#' @returns `data`, invisibly.
#' @family data checks
#' @export
#'
#' @examples
#' kb_check_data_canopy(data_canopy_sim_nereo)
kb_check_data_canopy <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      chk::chk_string(x_name)
      .chk_canopy_maps(data, x_name)
      warn_implausible_units(data, x_name)
      warn_group_names(data, x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
