#' Check Nereocystis weight data
#'
#' Check that `data` contains the columns required to fit the *Nereocystis
#' luetkeana* weight model, with appropriate types and values.
#'
#' @details
#' ```{r, echo = FALSE, results = "asis"}
#' cat(doc_data_columns("weight_nereo"))
#' ```
#'
#' `diameter_mm` is any plant diameter that relates to weight as a power law,
#' such as the maximum sub-bulb diameter, the diameter 15 cm below the
#' sub-bulb, or the bulb diameter. Required columns have no missing values;
#' other columns are ignored.
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
#'   site = factor(c("a", "b")), year = c(2020, 2021)
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
        data_column_names("weight_nereo"),
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
