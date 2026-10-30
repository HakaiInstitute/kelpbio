#' Check Macrocystis carbon data
#'
#' Check that `data` contains the columns required to fit the
#' *Macrocystis pyrifera* carbon model, with appropriate types and values.
#'
#' @inherit kb_check_data_carbon_nereo details return
#' @inheritParams kb_check_data_carbon_nereo
#'
#' @family data checks
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
      chk::chk_string(x_name)
      .chk_element_data(data, "carbon", x_name)
    },
    rlang::current_env()
  )
  invisible(data)
}
