#' Validate Macrocystis Wet/Dry Model Data
#'
#' Check that `data` contains the columns required to fit the *Macrocystis
#' pyrifera* wet/dry model, with appropriate types and values.
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
#' @inheritParams kb_check_data_wetdry_nereo
#'
#' @return `data`, invisibly.
#' @family data
#' @export
#'
#' @examples
#' data <- data.frame(wet_mass_g = c(1.8, 4.6), dry_mass_g = c(0.22, 0.57))
#' kb_check_data_wetdry_macro(data)
kb_check_data_wetdry_macro <- function(
  data,
  x_name = chk::deparse_backtick_chk(substitute(data))
) {
  chk::chk_data(data, x_name = x_name)
  chk::chk_superset(
    names(data),
    c("wet_mass_g", "dry_mass_g"),
    x_name = x_name
  )

  for (col in c("wet_mass_g", "dry_mass_g")) {
    nm <- kb_xname(x_name, col)
    chk::chk_numeric(data[[col]], x_name = nm)
    chk::chk_not_any_na(data[[col]], x_name = nm)
    chk::chk_gt(data[[col]], value = 0, x_name = nm)
  }
  # The ratio must lie in (0, 1) for the Beta likelihood.
  if (any(data$dry_mass_g >= data$wet_mass_g)) {
    cli::cli_abort(
      "{kb_xname(x_name, 'dry_mass_g')} must be less than {.field wet_mass_g}."
    )
  }

  warn_dry_wet_ratio(data, x_name)
  warn_implausible_units(data, x_name)
  invisible(data)
}
