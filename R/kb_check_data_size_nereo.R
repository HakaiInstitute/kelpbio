#' Validate Nereocystis Size Model Data
#'
#' Check that `data` contains the columns required to fit the *Nereocystis
#' luetkeana* size model, with appropriate types and values.
#'
#' Required columns: numeric `diameter_mm` (mm, > 0), and factor or character
#' `site` and `year`, with no missing values.
#'
#' @details
#' `diameter_mm` is the maximum sub-bulb diameter of each plant, the same
#' measurement as the predictor of the weight model ([kb_fit_weight_nereo()]).
#' Other columns are ignored.
#'
#' @inheritParams params
#' @param data A data frame of size observations, one row per plant.
#' @param x_name A string naming `data` in error messages.
#'
#' @return `data`, invisibly.
#' @family data
#' @export
#'
#' @examples
#' data <- data.frame(
#'   diameter_mm = c(22, 41), site = factor(c("a", "b")),
#'   year = factor(c("2020", "2021"))
#' )
#' kb_check_data_size_nereo(data)
kb_check_data_size_nereo <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  chk::chk_data(data, x_name = x_name)
  chk::chk_superset(
    names(data),
    c("diameter_mm", "site", "year"),
    x_name = x_name
  )

  nm <- kb_xname(x_name, "diameter_mm")
  chk::chk_numeric(data$diameter_mm, x_name = nm)
  chk::chk_not_any_na(data$diameter_mm, x_name = nm)
  chk::chk_gt(data$diameter_mm, value = 0, x_name = nm)

  for (col in c("site", "year")) {
    nm <- kb_xname(x_name, col)
    chk::chk_character_or_factor(data[[col]], x_name = nm)
    chk::chk_not_any_na(data[[col]], x_name = nm)
  }

  warn_implausible_units(data, x_name)
  warn_group_names(data, x_name)
  invisible(data)
}
