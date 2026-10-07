#' Validate Nereocystis Weight Model Data
#'
#' Check that `data` contains the columns required to fit the *Nereocystis
#' luetkeana* weight model, with appropriate types and values.
#'
#' Required columns: numeric `diameter_mm` (mm, > 0), numeric `weight_kg` (kg, > 0),
#' and factor or character `site` and `year`, with no missing values.
#'
#' Optional column: numeric `stipes_m2`, the stipe density (stipes per m²) of the
#' plant's site-year, `>= 0` with `NA` where not recorded. Rows from the same
#' site-year must not have different values.
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
      chk::chk_data(data, x_name = x_name)
      chk::chk_superset(
        names(data),
        c("diameter_mm", "weight_kg", "site", "year"),
        x_name = x_name
      )
      .chk_measure_columns(data, c("diameter_mm", "weight_kg"), x_name)
      .chk_group_columns(data, x_name)
      if ("stipes_m2" %in% names(data)) {
        .chk_density(data$stipes_m2, x_name = column_xname(x_name, "stipes_m2"))
        .chk_density_site_year(data, x_name = x_name)
      }
      warn_implausible_units(data, x_name)
      warn_group_names(data, x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
