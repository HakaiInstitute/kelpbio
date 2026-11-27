#' Check a Macrocystis size census
#'
#' Check that `data` has the columns and values of a census of every
#' *Macrocystis pyrifera* plant counted by in situ surveys, for
#' [kb_predict_biomass_in_situ()].
#'
#' @details
#' Each row is one counted plant; its site and year are those of its survey.
#'
#' ```{r, echo = FALSE, results = "asis"}
#' cat(doc_data_columns("size_census_macro"))
#' ```
#'
#' @inheritParams params
#' @param data A data frame of counted plants, one row per plant.
#'
#' @returns `data`, invisibly.
#' @family data checks
#' @seealso [kb_fit_size_nereo()] for sizes from a sample when plants were
#'   tallied rather than measured.
#' @export
#'
#' @examples
#' kb_check_data_size_census_macro(data_size_census_sim_macro)
kb_check_data_size_census_macro <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      chk::chk_string(x_name)
      .chk_size_census_data(data, "fronds", x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
