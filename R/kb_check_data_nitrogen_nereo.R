#' Check Nereocystis nitrogen data
#'
#' Check that `data` contains the columns required to fit the
#' *Nereocystis luetkeana* nitrogen model, with appropriate types and values.
#'
#' @details
#' Each row is one dried tissue sample.
#'
#' ```{r, echo = FALSE, results = "asis"}
#' cat(doc_data_columns("nitrogen_nereo"))
#' ```
#'
#' A warning gives the number of samples whose nitrogen fraction (nitrogen mass
#' over sample mass) falls outside 0.002 to 0.05, the plausible range for kelp
#' tissue; they are kept.
#'
#' @inheritParams params
#' @param data A data frame of nitrogen observations, one row per sample.
#'
#' @returns `data`, invisibly.
#' @family data checks
#' @export
#'
#' @examples
#' data <- data.frame(sample_mass_mg = c(2.5, 2.3), nitrogen_mass_ug = c(48, 41))
#' kb_check_data_nitrogen_nereo(data)
kb_check_data_nitrogen_nereo <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      chk::chk_string(x_name)
      .chk_element_data(data, "nitrogen", x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
