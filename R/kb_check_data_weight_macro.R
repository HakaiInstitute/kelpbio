#' Validate Macrocystis Weight Model Data
#'
#' Check that `data` contains the columns required to fit the *Macrocystis
#' pyrifera* weight model, with appropriate types and values.
#'
#' Required columns: whole-number `fronds` (> 0), numeric `weight_kg` (kg, > 0), and
#' factor or character `site` and `year`, with no missing values.
#'
#' @details
#' `fronds` is the frond count used as the size predictor (in the Hakai surveys,
#' the number of fronds at least 1 m long with recorded biomass).
#'
#' @param data A data frame of weight observations, one row per plant.
#' @param x_name A string naming `data` in error messages.
#'
#' @return `data`, invisibly.
#' @family data
#' @export
#'
#' @examples
#' data <- data.frame(
#'   fronds = c(3, 8), weight_kg = c(0.4, 1.7),
#'   site = factor(c("a", "b")), year = factor(c("2020", "2021"))
#' )
#' kb_check_data_weight_macro(data)
kb_check_data_weight_macro <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
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
