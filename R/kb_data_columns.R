#' Data dictionary
#'
#' The columns of each data frame that kelpbio fits or predicts from, with
#' their types, units, allowed values, and examples.
#'
#' @details
#' Each dataset is the data frame checked by the data check of the same name:
#' `"weight_nereo"` by [kb_check_data_weight_nereo()], `"in_situ"` by
#' [kb_check_data_in_situ()], and so on. A required column must be present; a
#' required column has no missing values unless `allowed` says otherwise.
#' Grouping columns (`site`, `year`, `survey_id`) may also be factors, and a
#' numeric `year` or `survey_id` is used as its character value. Other columns
#' are ignored.
#'
#' The `in_situ` column `plants` is required when sizes come from a size sample
#' and must be absent when they come from a size census. The `in_situ` columns
#' `plot_area_m2`, `canopy_area_m2`, and `canopy_tide_height_m` are given
#' together for a survey with canopy imagery, or left missing together.
#'
#' @param dataset A string of the dataset to describe, one of
#'   `kb_data_columns()$dataset`, or `NULL` for every dataset.
#'
#' @returns A tibble with one row per dataset and column and the character
#'   columns `dataset`, `column`, `type` (`"numeric"`, `"integer"`,
#'   `"character"`, `"logical"`, or `"rvar"`), `units` (`NA` for none),
#'   `allowed` (the values accepted), `description`, and `example` (a typical
#'   value), and the logical column `required`.
#' @family data checks
#' @export
#'
#' @examples
#' kb_data_columns("weight_nereo")
#' unique(kb_data_columns()$dataset)
kb_data_columns <- function(dataset = NULL) {
  chk::chk_null_or(dataset, vld = chk::vld_string)
  if (is.null(dataset)) {
    return(data_columns)
  }
  chk::chk_subset(dataset, unique(data_columns$dataset))
  data_columns[data_columns$dataset == dataset, ]
}
