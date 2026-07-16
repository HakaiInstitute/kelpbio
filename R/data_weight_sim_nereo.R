#' Simulated Nereocystis Weight Dataset
#'
#' A small simulated dataset of sub-bulb diameter and wet weight (columns
#' `diameter`, `weight`, `site`, `year`), for fast tests and runnable examples. It
#' is simulated from the weight-model structure (site intercept, site slope, and
#' site:year random effects over a wide diameter range), not real survey data,
#' and is not intended for inference. Built by `data-raw/data_weight_sim_nereo.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{diameter}{Sub-bulb diameter (mm), a positive number.}
#'   \item{weight}{Wet weight (kg), a positive number.}
#'   \item{site}{Survey site, a factor (10 levels).}
#'   \item{year}{Survey year, a factor (4 levels).}
#' }
#' @seealso [fit_weight_sim_nereo] for a fit to this dataset.
#' @family data
"data_weight_sim_nereo"
