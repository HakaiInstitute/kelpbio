#' Validate Macrocystis Weight Model Data
#'
#' Check that `data` contains the columns required to fit the *Macrocystis
#' pyrifera* weight model, with appropriate types and values.
#'
#' Required columns: whole-number `fronds` (> 0), numeric `weight` (> 0), and
#' factor or character `site` and `year`, with no missing values.
#'
#' @details
#' `fronds` is the frond count used as the size predictor (in the Hakai surveys,
#' the number of fronds at least 1 m long with recorded biomass). `weight` may be
#' in any units, provided prediction data use the same units as the fitted data.
#'
#' @inheritParams params
#' @param x_name A string naming `data` in error messages.
#'
#' @return `data`, invisibly.
#' @family data
#' @export
#'
#' @examples
#' data <- data.frame(
#'   fronds = c(3, 8), weight = c(0.4, 1.7),
#'   site = factor(c("a", "b")), year = factor(c("2020", "2021"))
#' )
#' kb_check_data_weight_macro(data)
kb_check_data_weight_macro <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  chk::chk_data(data, x_name = x_name)
  chk::chk_superset(
    names(data),
    c("fronds", "weight", "site", "year"),
    x_name = x_name
  )

  nm <- kb_xname(x_name, "fronds")
  chk::chk_numeric(data$fronds, x_name = nm)
  chk::chk_not_any_na(data$fronds, x_name = nm)
  chk::chk_gt(data$fronds, value = 0, x_name = nm)
  chk::chk_whole_numeric(data$fronds, x_name = nm)

  nm <- kb_xname(x_name, "weight")
  chk::chk_numeric(data$weight, x_name = nm)
  chk::chk_not_any_na(data$weight, x_name = nm)
  chk::chk_gt(data$weight, value = 0, x_name = nm)

  for (col in c("site", "year")) {
    nm <- kb_xname(x_name, col)
    chk::chk_character_or_factor(data[[col]], x_name = nm)
    chk::chk_not_any_na(data[[col]], x_name = nm)
  }

  invisible(data)
}
