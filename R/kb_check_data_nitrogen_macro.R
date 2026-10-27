#' Check Macrocystis nitrogen data
#'
#' Check that `data` contains the columns required to fit the
#' *Macrocystis pyrifera* nitrogen model, with appropriate types and values.
#'
#' Required columns: numeric `sample_mass_mg` (mg, > 0) and `nitrogen_mass_ug`
#' (µg, > 0), with no missing values and the nitrogen mass less than the sample
#' mass.
#'
#' @details
#' Each row is one dried tissue sample: `sample_mass_mg` is the mass of the
#' sample analysed and `nitrogen_mass_ug` the nitrogen measured in it. The
#' model's response is the nitrogen fraction, the nitrogen mass divided by the
#' sample mass (`nitrogen_mass_ug` converted to mg). A warning gives the number
#' of samples whose nitrogen fraction falls outside 0.002 to 0.05, the plausible
#' range for kelp tissue; they are kept, not removed. Other columns are
#' ignored.
#'
#' @inheritParams kb_check_data_nitrogen_nereo
#'
#' @returns `data`, invisibly.
#' @family data checks
#' @export
#'
#' @examples
#' data <- data.frame(sample_mass_mg = c(2.4, 2.7), nitrogen_mass_ug = c(45, 52))
#' kb_check_data_nitrogen_macro(data)
kb_check_data_nitrogen_macro <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      chk::chk_string(x_name)
      .chk_nitrogen_data(data, x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
