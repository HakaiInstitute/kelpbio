#' Simulated Macrocystis Wet/Dry Dataset
#'
#' A small simulated dataset of sample wet and dry masses (columns `wet_mass_g`,
#' `dry_mass_g`), one row per tissue sample, for fast tests and runnable examples.
#' It is simulated from the wet/dry model structure (a Beta dry:wet mass ratio with
#' a mean and precision common to all samples), not real lab data, and is not
#' intended for inference. Built by `data-raw/data_wetdry_sim_macro.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{wet_mass_g}{Wet mass of the sample (g), a positive number.}
#'   \item{dry_mass_g}{Dry mass of the sample (g), a positive number less than
#'     `wet_mass_g`.}
#' }
#' @seealso [fit_wetdry_sim_macro] for a fit to this dataset.
#' @family data
"data_wetdry_sim_macro"
