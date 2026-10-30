#' Check Macrocystis wet/dry data
#'
#' Check that `data` contains the columns required to fit the *Macrocystis
#' pyrifera* wet/dry model, with appropriate types and values.
#'
#' @inherit kb_check_data_wetdry_nereo details return
#' @inheritParams kb_check_data_wetdry_nereo
#'
#' @family data checks
#' @export
#'
#' @examples
#' data <- data.frame(wet_mass_g = c(1.8, 4.6), dry_mass_g = c(0.22, 0.57))
#' kb_check_data_wetdry_macro(data)
kb_check_data_wetdry_macro <- function(
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
