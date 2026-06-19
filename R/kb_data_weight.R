#' Nereocystis Weight Dataset
#'
#' *Nereocystis luetkeana* sub-bulb diameter and wet weight from the Hakai
#' Institute allometry surveys, the data the coastwide weight model is fit to.
#' One row per harvested individual, across multiple sites and years. Prepared
#' from the analysis project (Hakai-only records, maximum sub-bulb measurements,
#' completeness and outlier screening); built by `data-raw/kb_data_weight.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{diameter}{Sub-bulb diameter (mm), a positive number.}
#'   \item{weight}{Wet weight (kg), a positive number.}
#'   \item{site}{Survey site, a factor.}
#'   \item{year}{Survey year, a factor.}
#' }
#' @family data
"kb_data_weight"
