#' Validate Nereocystis Density Model Data
#'
#' Check that `data` contains the columns required to fit the *Nereocystis
#' luetkeana* density model, with appropriate types and values.
#'
#' Required columns: whole-number `stipes` (>= 0), numeric `area_m2` (m², > 0),
#' factor or character `site`, and factor, character, or whole-number `year`,
#' with no missing values.
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
#'   year = c(2020, 2021)
#' )
#' kb_check_data_density_nereo(data)
kb_check_data_density_nereo <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      chk::chk_data(data, x_name = x_name)
      chk::chk_superset(
        names(data),
        c("stipes", "area_m2", "site", "year"),
        x_name = x_name
      )
      .chk_measure_columns(data, "stipes", x_name, count = TRUE, zero = TRUE)
      .chk_measure_columns(data, "area_m2", x_name)
      .chk_group_columns(data, x_name)
      warn_implausible_units(data, x_name)
      warn_group_names(data, x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
