#' Validate Weight Model Input Data
#'
#' Check that `data` contains the columns required to fit the weight model, with
#' appropriate types and values. Returns the data invisibly on success and
#' errors otherwise.
#'
#' Required columns: numeric `diameter` (> 0), numeric `weight` (> 0), and
#' factor or character `site` and `year`.
#'
#' @inheritParams params
#'
#' @return `data`, invisibly.
#' @export
#'
#' @examples
#' data <- data.frame(
#'   diameter = c(20, 35), weight = c(0.5, 2.1),
#'   site = factor(c("a", "b")), year = factor(c("2020", "2021"))
#' )
#' kb_check_data_weight(data)
kb_check_data_weight <- function(data) {
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame, not {.obj_type_friendly {data}}.")
  }

  required <- c("diameter", "weight", "site", "year")
  missing <- setdiff(required, names(data))
  if (length(missing)) {
    cli::cli_abort("{.arg data} is missing required column{?s}: {.field {missing}}.")
  }

  for (col in c("diameter", "weight")) {
    x <- data[[col]]
    if (!is.numeric(x)) {
      cli::cli_abort(
        "Column {.field {col}} must be numeric, not {.obj_type_friendly {x}}."
      )
    }
    if (any(x <= 0, na.rm = TRUE)) {
      cli::cli_abort("Column {.field {col}} must be positive (> 0).")
    }
  }

  for (col in c("site", "year")) {
    x <- data[[col]]
    if (!is.factor(x) && !is.character(x)) {
      cli::cli_abort(
        "Column {.field {col}} must be a factor or character, not {.obj_type_friendly {x}}."
      )
    }
  }

  invisible(data)
}
