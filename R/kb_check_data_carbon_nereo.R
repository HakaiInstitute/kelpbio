#' Check Nereocystis carbon data
#'
#' Check that `data` contains the columns required to fit the
#' *Nereocystis luetkeana* carbon model, with appropriate types and values.
#'
#' @details
#' Each row is one dried tissue sample. Required columns, with no missing
#' values:
#'
#' - `sample_mass_mg`, the mass of the sample analysed (mg, > 0).
#' - `carbon_mass_ug`, the carbon measured in it (µg, > 0 and less than the sample
#'   mass).
#'
#' The model's response is the carbon fraction, the carbon mass divided by the
#' sample mass (`carbon_mass_ug` converted to mg). A warning gives the number of
#' samples whose carbon fraction falls outside 0.10 to 0.50, the plausible range for
#' kelp tissue; they are kept, not removed. Other columns are ignored.
#'
#' @inheritParams params
#' @param data A data frame of carbon observations, one row per sample.
#'
#' @returns `data`, invisibly.
#' @family data checks
#' @export
#'
#' @examples
#' data <- data.frame(sample_mass_mg = c(2.5, 2.3), carbon_mass_ug = c(650, 610))
#' kb_check_data_carbon_nereo(data)
kb_check_data_carbon_nereo <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      chk::chk_string(x_name)
      .chk_element_data(data, "carbon", x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
