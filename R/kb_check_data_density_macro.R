#' Validate Macrocystis Density Model Data
#'
#' Check that `data` contains the columns required to fit the *Macrocystis
#' pyrifera* density model, with appropriate types and values.
#'
#' Required columns: whole-number `plants` (>= 0), numeric `area_m2` (m², > 0),
#' and factor or character `site` and `year`, with no missing values.
#'
#' @details
#' Each row is one transect: `plants` is the number of plants counted on it and
#' `area_m2` the area surveyed. Plants recorded individually should be counted to
#' one row per transect before fitting. A count of zero is valid. Other columns
#' are ignored.
#'
#' @inheritParams kb_check_data_density_nereo
#'
#' @return `data`, invisibly.
#' @family data
#' @export
#'
#' @examples
#' data <- data.frame(
#'   plants = c(15, 3), area_m2 = c(40, 60), site = factor(c("a", "b")),
#'   year = factor(c("2020", "2021"))
#' )
#' kb_check_data_density_macro(data)
kb_check_data_density_macro <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  chk::chk_data(data, x_name = x_name)
  chk::chk_superset(
    names(data),
    c("plants", "area_m2", "site", "year"),
    x_name = x_name
  )

  nm <- kb_xname(x_name, "plants")
  chk::chk_numeric(data$plants, x_name = nm)
  chk::chk_not_any_na(data$plants, x_name = nm)
  chk::chk_gte(data$plants, value = 0, x_name = nm)
  chk::chk_whole_numeric(data$plants, x_name = nm)

  nm <- kb_xname(x_name, "area_m2")
  chk::chk_numeric(data$area_m2, x_name = nm)
  chk::chk_not_any_na(data$area_m2, x_name = nm)
  chk::chk_gt(data$area_m2, value = 0, x_name = nm)

  for (col in c("site", "year")) {
    nm <- kb_xname(x_name, col)
    chk::chk_character_or_factor(data[[col]], x_name = nm)
    chk::chk_not_any_na(data[[col]], x_name = nm)
  }

  warn_implausible_units(data, x_name)
  invisible(data)
}
