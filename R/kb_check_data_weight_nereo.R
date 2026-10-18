#' Check Nereocystis weight data
#'
#' Check that `data` contains the columns required to fit the *Nereocystis
#' luetkeana* weight model, with appropriate types and values.
#'
#' Required columns: numeric `diameter_mm` (mm, > 0), numeric `weight_kg` (kg, > 0),
#' and factor or character `site` and `year`, with no missing values.
#'
#' @inheritParams params
#' @param data A data frame of weight observations, one row per plant.
#'
#' @returns `data`, invisibly.
#' @family data checks
#' @export
#'
#' @examples
#' data <- data.frame(
#'   diameter_mm = c(20, 35), weight_kg = c(0.5, 2.1),
#'   site = factor(c("a", "b")), year = factor(c("2020", "2021"))
#' )
#' kb_check_data_weight_nereo(data)
kb_check_data_weight_nereo <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      chk::chk_string(x_name)
      chk::chk_data(data, x_name = x_name)
      chk::chk_superset(
        names(data),
        c("diameter_mm", "weight_kg", "site", "year"),
        x_name = x_name
      )
      .chk_measure_columns(data, c("diameter_mm", "weight_kg"), x_name)
      .chk_group_columns(data, x_name)
      warn_implausible_units(data, x_name)
      warn_group_names(data, x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
