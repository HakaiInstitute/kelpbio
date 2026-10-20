#' Check Nereocystis size sample data
#'
#' Check that `data` contains the columns required to fit the *Nereocystis
#' luetkeana* size model, with appropriate types and values.
#'
#' Required columns: numeric `diameter_mm` (mm, > 0), factor or character
#' `site`, and `year` (factor, character, or whole numbers), with no missing
#' values.
#'
#' @details
#' Each row is one plant of a sample measured for the size model, which need
#' not be linked to any survey. `diameter_mm` is the maximum sub-bulb diameter,
#' the same measurement as the predictor of the weight model
#' ([kb_fit_weight_nereo()]). A numeric `year` is used as its character level.
#' Other columns are ignored.
#'
#' @inheritParams params
#' @param data A data frame of size observations, one row per plant.
#'
#' @returns `data`, invisibly.
#' @family data checks
#' @seealso [kb_check_data_size_census_nereo()] for every plant a survey
#'   counted.
#' @export
#'
#' @examples
#' data <- data.frame(
#'   diameter_mm = c(22, 41), site = factor(c("a", "b")), year = c(2020, 2021)
#' )
#' kb_check_data_size_sample_nereo(data)
kb_check_data_size_sample_nereo <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      chk::chk_string(x_name)
      chk::chk_data(data, x_name = x_name)
      chk::chk_superset(
        names(data),
        c("diameter_mm", "site", "year"),
        x_name = x_name
      )
      .chk_measure_columns(data, "diameter_mm", x_name)
      .chk_group_columns(data, x_name)
      warn_implausible_units(data, x_name)
      warn_group_names(data, x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
