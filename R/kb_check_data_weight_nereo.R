#' Validate Nereocystis Weight Model Data
#'
#' Check that `data` contains the columns required to fit the *Nereocystis
#' luetkeana* weight model, with appropriate types and values.
#'
#' Required columns: numeric `diameter` (mm, > 0), numeric `weight` (kg, > 0),
#' and factor or character `site` and `year`, with no missing values.
#'
#' Optional column: numeric `density`, the stipe density (stipes per m²) of the
#' plant's site-year, `>= 0` with `NA` where not recorded. Rows from the same
#' site-year must not have different values.
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
#'   diameter = c(20, 35), weight = c(0.5, 2.1),
#'   site = factor(c("a", "b")), year = factor(c("2020", "2021"))
#' )
#' kb_check_data_weight_nereo(data)
kb_check_data_weight_nereo <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  chk::chk_data(data, x_name = x_name)
  chk::chk_superset(
    names(data),
    c("diameter", "weight", "site", "year"),
    x_name = x_name
  )

  for (col in c("diameter", "weight")) {
    nm <- kb_xname(x_name, col)
    chk::chk_numeric(data[[col]], x_name = nm)
    chk::chk_not_any_na(data[[col]], x_name = nm)
    chk::chk_gt(data[[col]], value = 0, x_name = nm)
  }

  for (col in c("site", "year")) {
    nm <- kb_xname(x_name, col)
    chk::chk_character_or_factor(data[[col]], x_name = nm)
    chk::chk_not_any_na(data[[col]], x_name = nm)
  }

  if ("density" %in% names(data)) {
    .chk_density(data$density, x_name = kb_xname(x_name, "density"))
    .chk_density_site_year(data, x_name = x_name)
  }

  warn_implausible_units(data, x_name)
  invisible(data)
}

# Column-qualified name for chk error messages (bboudata convention).
kb_xname <- function(x_name, col) {
  paste0("Column `", col, "` of ", x_name)
}
