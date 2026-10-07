#' Validate Nereocystis Wet/Dry Model Data
#'
#' Check that `data` contains the columns required to fit the *Nereocystis
#' luetkeana* wet/dry model, with appropriate types and values.
#'
#' Required columns: numeric `wet_mass_g` and `dry_mass_g` (g, > 0), with
#' `dry_mass_g` less than `wet_mass_g` and no missing values.
#'
#' @details
#' Each row is one tissue sample: `wet_mass_g` is its mass before drying and
#' `dry_mass_g` after. A warning gives the number of samples whose dry:wet ratio
#' falls outside 0.02 to 0.5, the plausible range for kelp tissue; they are kept,
#' not removed. Other columns are ignored.
#'
#' @param data A data frame of wet/dry observations, one row per sample.
#' @param x_name A string naming `data` in error messages.
#'
#' @return `data`, invisibly.
#' @family data
#' @export
#'
#' @examples
#' data <- data.frame(wet_mass_g = c(12.4, 58.7), dry_mass_g = c(1.1, 5.0))
#' kb_check_data_wetdry_nereo(data)
kb_check_data_wetdry_nereo <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  .with_call(
    {
      .chk_wetdry_data(data, x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
