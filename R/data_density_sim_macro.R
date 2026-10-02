#' Simulated Macrocystis Density Dataset
#'
#' A small simulated dataset of plant counts on transects (columns `plants`,
#' `area_m2`, `site`, `year`), one row per transect, for fast tests and runnable
#' examples. It is simulated from the density-model structure (a negative binomial
#' with the transect area as an offset and site, year, and site:year effects on
#' log density), not real survey data, and is not intended for inference. Built by
#' `data-raw/data_density_sim_macro.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{plants}{Number of plants counted on the transect, a whole number of at
#'     least 0.}
#'   \item{area_m2}{Area surveyed (m²), a positive number.}
#'   \item{site}{Survey site, a factor (10 levels).}
#'   \item{year}{Survey year, a factor (4 levels).}
#' }
#' @seealso [fit_density_sim_macro] for a fit to this dataset.
#' @family data
"data_density_sim_macro"
