#' Validate Nereocystis Density Model Data
#'
#' Check that `data` contains the columns required to fit the *Nereocystis
#' luetkeana* density model, with appropriate types and values.
#'
#' Required columns: whole-number `stipes` (>= 0), numeric `area_m2` (m², > 0),
#' and factor or character `site` and `year`, with no missing values.
#'
#' @details
#' Each row is one transect: `stipes` is the number of stipes counted on it and
#' `area_m2` the area surveyed. Counts recorded in bins along a transect should be
#' summed, with their areas, to one row per transect before fitting. A count of
#' zero is valid. Other columns are ignored.
#'
#' @param data A data frame of density observations, one row per transect.
#' @param x_name A string naming `data` in error messages.
#'
#' @return `data`, invisibly.
#' @family data
#' @export
#'
#' @examples
#' data <- data.frame(
#'   stipes = c(12, 0), area_m2 = c(40, 20), site = factor(c("a", "b")),
#'   year = factor(c("2020", "2021"))
#' )
#' kb_check_data_density_nereo(data)
kb_check_data_density_nereo <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  chk::chk_data(data, x_name = x_name)
  chk::chk_superset(
    names(data),
    c("stipes", "area_m2", "site", "year"),
    x_name = x_name
  )

  nm <- kb_xname(x_name, "stipes")
  chk::chk_numeric(data$stipes, x_name = nm)
  chk::chk_not_any_na(data$stipes, x_name = nm)
  chk::chk_gte(data$stipes, value = 0, x_name = nm)
  chk::chk_whole_numeric(data$stipes, x_name = nm)

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
