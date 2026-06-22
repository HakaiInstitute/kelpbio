#' Hakai Nereocystis Weight Dataset
#'
#' *Nereocystis luetkeana* sub-bulb diameter and wet weight from the Hakai
#' Institute allometry surveys, the data the coastwide weight model is fit to.
#' One row per harvested individual, across multiple sites and years. Built by
#' `data-raw/data_weight_hakai_nereo.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{diameter}{Sub-bulb diameter (mm), a positive number.}
#'   \item{weight}{Wet weight (kg), a positive number.}
#'   \item{site}{Survey site, a factor.}
#'   \item{year}{Survey year, a factor.}
#' }
#' @seealso [data_weight_sim_nereo] for a simulated dataset, and [kb_fit_weight_nereo()].
#' @family data
"data_weight_hakai_nereo"
