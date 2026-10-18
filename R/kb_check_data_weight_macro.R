#' Check Macrocystis weight data
#'
#' Check that `data` contains the columns required to fit the *Macrocystis
#' pyrifera* weight model, with appropriate types and values.
#'
#' Required columns: whole-number `fronds` (> 0), numeric `weight_kg` (kg, > 0),
#' factor or character `site`, and `date` (a `Date`), with no missing values.
#'
#' @details
#' `fronds` is the number of fronds reaching 1 m above the holdfast, used as the
#' size predictor. The year of each row is the year of `date`; a `year` column,
#' if present, must agree with it. Other columns are ignored.
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
#'   site = factor(c("a", "b")), date = as.Date(c("2020-08-10", "2021-08-12"))
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
        c("fronds", "weight_kg", "site", "date"),
        x_name = x_name
      )
      .chk_measure_columns(data, "fronds", x_name, count = TRUE)
      .chk_measure_columns(data, "weight_kg", x_name)
      .chk_dated_site(data, x_name)
      warn_implausible_units(data, x_name)
      warn_group_names(data, x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
