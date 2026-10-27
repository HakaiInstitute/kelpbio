#' Check Nereocystis wet/dry data
#'
#' Check that `data` contains the columns required to fit the *Nereocystis
#' luetkeana* wet/dry model, with appropriate types and values.
#'
#' @details
#' Each row is one tissue sample. Required columns, with no missing values:
#'
#' - `wet_mass_g`, its mass before drying (g, > 0).
#' - `dry_mass_g`, its mass after drying (g, > 0 and less than `wet_mass_g`).
#'
#' A warning gives the number of samples whose dry:wet ratio falls outside 0.02
#' to 0.50, the plausible range for kelp tissue; they are kept, not removed.
#' Other columns are ignored.
#'
#' @inheritParams params
#' @param data A data frame of wet/dry observations, one row per sample.
#'
#' @returns `data`, invisibly.
#' @family data checks
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
      chk::chk_string(x_name)
      .chk_wetdry_data(data, x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
