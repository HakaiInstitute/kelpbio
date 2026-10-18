#' Check Nereocystis plant data
#'
#' Check that `data` has the columns and values of a table of every counted
#' *Nereocystis luetkeana* plant, for [kb_predict_biomass_survey()].
#'
#' @details
#' Each row is one counted plant, an individual (sporophyte) identified by its
#' holdfast. Required columns:
#'
#' - `site`, `plot_id`, and `date`, the survey the plant was counted in (see
#'   [kb_check_data_survey()]).
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
#' @export
#'
#' @examples
#' plants <- data.frame(
#'   site = "otter_cove", plot_id = "1", date = as.Date("2021-08-12"),
#'   diameter_mm = c(32, 41), partial = c(FALSE, TRUE)
#' )
#' kb_check_data_plants_nereo(plants)
kb_check_data_plants_nereo <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      chk::chk_string(x_name)
      .chk_plants_data(data, "diameter_mm", x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
