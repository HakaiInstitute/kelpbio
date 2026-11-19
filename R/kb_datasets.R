#' Datasets
#'
#' The datasets that kelpbio fits or predicts from, with what one row of each
#' holds. [kb_data_columns()] gives each dataset's columns.
#'
#' @param dataset A string of the dataset to describe, one of
#'   `kb_datasets()$dataset`, or `NULL` for every dataset.
#'
#' @returns A tibble with one row per dataset and the character columns
#'   `dataset` and `row` (what one row of the dataset holds, as markdown with
#'   column names in backticks).
#' @family data checks
#' @export
#'
#' @examples
#' kb_datasets()
#' kb_datasets("survey_canopy")
kb_datasets <- function(dataset = NULL) {
  chk::chk_null_or(dataset, vld = chk::vld_string)
  if (is.null(dataset)) {
    return(data_rows)
  }
  chk::chk_subset(dataset, data_rows$dataset)
  data_rows[data_rows$dataset == dataset, ]
}
