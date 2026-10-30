#' Check Macrocystis weight data
#'
#' Check that `data` contains the columns required to fit the *Macrocystis
#' pyrifera* weight model, with appropriate types and values.
#'
#' @details
#' Required columns, with no missing values:
#'
#' - `fronds`, the number of fronds reaching 1 m above the holdfast, the size
#'   predictor (a whole number of at least 1).
#' - `weight_kg`, the plant's weight (kg, > 0).
#' - `site`, factor or character.
#' - `year`, factor, character, or whole numbers. A numeric `year` is used as
#'   its character level.
#'
#' Other columns are ignored.
#'
#' @inheritParams kb_check_data_weight_nereo
#' @inheritParams params
#' @returns `data`, invisibly.
#' @family data checks
#' @export
#'
#' @examples
#' data <- data.frame(
#'   fronds = c(3, 8), weight_kg = c(0.4, 1.7),
#'   site = factor(c("a", "b")), year = c(2020, 2021)
#' )
#' kb_check_data_weight_macro(data)
kb_check_data_weight_macro <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      chk::chk_string(x_name)
      chk::chk_data(data, x_name = x_name)
      chk::chk_superset(
        names(data),
        c("fronds", "weight_kg", "site", "year"),
        x_name = x_name
      )
      .chk_measure_columns(data, "fronds", x_name, count = TRUE)
      .chk_measure_columns(data, "weight_kg", x_name)
      .chk_group_columns(data, x_name)
      warn_implausible_units(data, x_name)
      warn_group_names(data, x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
