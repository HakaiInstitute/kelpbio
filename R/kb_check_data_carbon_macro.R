#' Validate Macrocystis Carbon Model Data
#'
#' Check that `data` contains the columns required to fit the
#' *Macrocystis pyrifera* carbon model, with appropriate types and values.
#'
#' Required columns: numeric `sample_mass_mg` (mg, > 0) and `carbon_mass_ug`
#' (µg, > 0), with no missing values and the carbon mass less than the sample
#' mass.
#'
#' @details
#' Each row is one dried tissue sample, as reported by the isotope lab:
#' `sample_mass_mg` is the mass of the sample analysed and `carbon_mass_ug` the
#' carbon measured in it. The model's response is the carbon fraction,
#' `carbon_mass_ug / 1000 / sample_mass_mg`. A warning gives the number of samples
#' whose carbon fraction falls outside 0.10 to 0.50, the plausible range for kelp
#' tissue; they are kept, not removed. Other columns are ignored.
#'
#' @inheritParams kb_check_data_carbon_nereo
#'
#' @return `data`, invisibly.
#' @family data
#' @export
#'
#' @examples
#' data <- data.frame(sample_mass_mg = c(2.4, 2.7), carbon_mass_ug = c(760, 850))
#' kb_check_data_carbon_macro(data)
kb_check_data_carbon_macro <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      .chk_carbon_data(data, x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
