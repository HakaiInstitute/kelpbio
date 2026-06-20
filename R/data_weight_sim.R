#' Simulated Nereocystis Weight Dataset
#'
#' A small simulated dataset of sub-bulb diameter and wet weight with the same
#' columns as [data_weight_hakai], for fast tests and runnable examples. It is
#' simulated from the weight-model structure, not real survey data, and is not
#' intended for inference. Built by `data-raw/data_weight_sim.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{diameter}{Sub-bulb diameter (mm), a positive number.}
#'   \item{weight}{Wet weight (kg), a positive number.}
#'   \item{site}{Survey site, a factor (6 levels).}
#'   \item{year}{Survey year, a factor (4 levels).}
#' }
#' @seealso [data_weight_hakai] for the real survey data, and
#'   [fit_weight] for a fit to this dataset.
#' @family data
"data_weight_sim"
