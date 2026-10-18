#' Check Nereocystis size data
#'
#' Check that `data` contains the columns required to fit the *Nereocystis
#' luetkeana* size model, with appropriate types and values.
#'
#' Required columns: numeric `diameter_mm` (mm, > 0), factor or character
#' `site`, and `date` (a `Date`), with no missing values.
#'
#' @details
#' `diameter_mm` is the maximum sub-bulb diameter of each plant, the same
#' measurement as the predictor of the weight model ([kb_fit_weight_nereo()]).
#' The year of each row is the year of `date`; a `year` column, if present,
#' must agree with it. An optional `plot_id` (factor or character) records the
#' plot a plant was measured on; the model works at site-year resolution and
#' does not use it. Other columns are ignored.
#'
#' @inheritParams params
#' @param data A data frame of size observations, one row per plant.
#'
#' @returns `data`, invisibly.
#' @family data checks
#' @export
#'
#' @examples
#' data <- data.frame(
#'   diameter_mm = c(22, 41), site = factor(c("a", "b")),
#'   date = as.Date(c("2020-08-10", "2021-08-12"))
#' )
#' kb_check_data_size_nereo(data)
kb_check_data_size_nereo <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      chk::chk_string(x_name)
      chk::chk_data(data, x_name = x_name)
      chk::chk_superset(
        names(data),
        c("diameter_mm", "site", "date"),
        x_name = x_name
      )
      .chk_measure_columns(data, "diameter_mm", x_name)
      .chk_dated_site(data, x_name)
      if ("plot_id" %in% names(data)) {
        .chk_group_columns(data, x_name, "plot_id")
      }
      warn_implausible_units(data, x_name)
      warn_group_names(data, x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
