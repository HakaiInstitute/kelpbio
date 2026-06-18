#' Simulated Weight Dataset
#'
#' A small simulated dataset of *Nereocystis luetkeana* sub-bulb diameter and
#' wet weight across several sites and years, for use in examples and tests. One
#' site-year cell is intentionally absent. This is simulated data, not real
#' survey data. Built by `data-raw/kb_data_weight.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{diameter}{Sub-bulb diameter (mm), a positive number.}
#'   \item{weight}{Wet weight (kg), a positive number.}
#'   \item{site}{Survey site, a factor.}
#'   \item{year}{Survey year, a factor.}
#' }
"kb_data_weight"
