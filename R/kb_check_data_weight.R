#' Validate Weight Model Input Data
#'
#' Check that `data` contains the columns required to fit the weight model, with
#' appropriate types and values. Returns the data invisibly on success and
#' errors via `chk` otherwise.
#'
#' Required columns: numeric `diameter_mm` (> 0), numeric `weight_kg` (> 0), and
#' factor or character `site` and `year`, with no missing values. Diameter is
#' the sub-bulb diameter in millimetres and weight the wet weight in kilograms;
#' the model centres diameter at 30 mm, so the units are part of the contract.
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
#'   diameter_mm = c(20, 35), weight_kg = c(0.5, 2.1),
#'   site = factor(c("a", "b")), year = factor(c("2020", "2021"))
#' )
#' kb_check_data_weight(data)
kb_check_data_weight <- function(data, x_name = deparse(substitute(data))) {
  chk::chk_data(data, x_name = x_name)
  chk::chk_superset(
    names(data),
    c("diameter_mm", "weight_kg", "site", "year"),
    x_name = x_name
  )

  for (col in c("diameter_mm", "weight_kg")) {
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
