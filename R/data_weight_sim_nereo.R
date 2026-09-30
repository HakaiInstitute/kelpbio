#' Simulated Nereocystis Weight Dataset
#'
#' A small simulated dataset of sub-bulb diameter, wet weight, and stipe density
#' (columns `diameter`, `weight`, `site`, `year`, `density`), for fast tests and
#' runnable examples. It is simulated from the weight-model structure (a
#' three-parameter power function with year, site, and site:year random effects
#' and a stipe density effect, over a wide diameter range), not real survey data,
#' and is not intended for inference. Built by `data-raw/data_weight_sim_nereo.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{diameter}{Sub-bulb diameter (mm), a positive number.}
#'   \item{weight}{Wet weight (kg), a positive number.}
#'   \item{site}{Survey site, a factor (10 levels).}
#'   \item{year}{Survey year, a factor (4 levels).}
#'   \item{density}{Stipe density of the site-year (stipes per m²), `NA` for
#'     three site-years without a recorded value.}
#' }
#' @seealso [fit_weight_sim_nereo] for a fit to this dataset.
#' @family data
"data_weight_sim_nereo"
