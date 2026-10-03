#' Simulated Nereocystis Carbon Dataset
#'
#' A small simulated dataset of sample and carbon masses (columns
#' `sample_mass_mg`, `carbon_mass_ug`), one row per dried tissue sample, for fast
#' tests and runnable examples. It is simulated from the carbon model structure (a
#' Beta carbon fraction with a mean and precision common to all samples), not real
#' lab data, and is not intended for inference. Built by
#' `data-raw/data_carbon_sim_nereo.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{sample_mass_mg}{Mass of the dried sample analysed (mg), a positive
#'     number.}
#'   \item{carbon_mass_ug}{Carbon measured in the sample (µg), a positive number
#'     less than the sample mass.}
#' }
#' @seealso [fit_carbon_sim_nereo] for a fit to this dataset.
#' @family data
"data_carbon_sim_nereo"
