#' Validate Nereocystis Weight Model Input Data
#'
#' Check that `data` contains the columns required to fit the *Nereocystis
#' luetkeana* weight model, with appropriate types and values, erroring if it
#' does not.
#'
#' Required columns: numeric `diameter` (> 0), numeric `weight` (> 0), and factor
#' or character `site` and `year`, with no missing values.
#'
#' @details
#' Units are the user's choice: the model centres log-diameter at the geometric
#' mean of the observed diameter, so the diameter unit does not affect the fit or
#' predictions, and weight is returned in whatever unit it was supplied in. The
#' only requirement is that prediction data use the same units as the fitted data.
#'
#' @inheritParams params
#' @param x_name A string naming `data` in error messages.
#'
#' @return `data`, invisibly; called for its side effect of validating `data`.
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
  x_name = deparse(substitute(data))
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

  invisible(data)
}

# Column-qualified name for chk error messages (bboudata convention).
kb_xname <- function(x_name, col) {
  paste0("Column `", col, "` of ", x_name)
}
