#' Check Nereocystis carbon data
#'
#' Check that `data` contains the columns required to fit the
#' *Nereocystis luetkeana* carbon model, with appropriate types and values.
#'
#' Required columns: numeric `sample_mass_mg` (mg, > 0) and `carbon_mass_ug`
#' (µg, > 0), with no missing values and the carbon mass less than the sample
#' mass.
#'
#' @details
#' Each row is one dried tissue sample: `sample_mass_mg` is the mass of the
#' sample analysed and `carbon_mass_ug` the carbon measured in it. The
#' model's response is the carbon fraction, the carbon mass divided by the
#' sample mass (`carbon_mass_ug` converted to mg). A warning gives the number
#' of samples whose carbon fraction falls outside 0.10 to 0.50, the plausible
#' range for kelp tissue; they are kept, not removed. Other columns are
#' ignored.
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
