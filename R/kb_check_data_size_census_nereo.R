#' Check a Nereocystis size census
#'
#' Check that `data` has the columns and values of a census of every
#' *Nereocystis luetkeana* plant counted by in situ surveys, for
#' [kb_predict_biomass_survey()].
#'
#' @details
#' Each row is one counted plant, an individual (sporophyte) identified by its
#' holdfast. Required columns:
#'
#' - `survey_id`, the survey the plant was counted in (see
#'   [kb_check_data_survey()]), which gives the plant's site and year.
#' - `diameter_mm`, the maximum sub-bulb diameter (mm, > 0), the predictor of
#'   the weight model ([kb_fit_weight_nereo()]).
#'
#' An optional logical `partial` marks plants counted as half, such as plants
#' on the edge of a transect. Other columns are ignored.
#'
#' @inheritParams params
#' @param data A data frame of counted plants, one row per plant.
#'
#' @returns `data`, invisibly.
#' @family data checks
#' @seealso [kb_check_data_size_sample_nereo()] for a sample measured for the
#'   size model.
#' @export
#'
#' @examples
#' size_census <- data.frame(
#'   survey_id = "s1", diameter_mm = c(32, 41), partial = c(FALSE, TRUE)
#' )
#' kb_check_data_size_census_nereo(size_census)
kb_check_data_size_census_nereo <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      chk::chk_string(x_name)
      .chk_size_census_data(data, "diameter_mm", x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
