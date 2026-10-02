#' Simulated Nereocystis Density Dataset
#'
#' A small simulated dataset of stipe counts on transects (columns `stipes`,
#' `area_m2`, `site`, `year`), one row per transect, for fast tests and runnable
#' examples. It is simulated from the density-model structure (a zero-inflated
#' negative binomial with the transect area as an offset and site, year, and
#' site:year effects on log density), not real survey data, and is not intended
#' for inference. Built by `data-raw/data_density_sim_nereo.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{stipes}{Number of stipes counted on the transect, a whole number of at
#'     least 0.}
#'   \item{area_m2}{Area surveyed (m²), a positive number.}
#'   \item{site}{Survey site, a factor (10 levels).}
#'   \item{year}{Survey year, a factor (4 levels).}
#' }
#' @seealso [fit_density_sim_nereo] for a fit to this dataset.
#' @family data
"data_density_sim_nereo"
