#' Simulated Nereocystis Size Dataset
#'
#' A small simulated dataset of maximum sub-bulb diameter (columns `diameter_mm`,
#' `site`, `year`), one row per plant, for fast tests and runnable examples. It is
#' simulated from the size-model structure (a Weibull distribution with site,
#' year, and site:year effects on the log mean), not real survey data, and is not
#' intended for inference. Built by `data-raw/data_size_sim_nereo.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{diameter_mm}{Maximum sub-bulb diameter (mm), a positive number.}
#'   \item{site}{Survey site, a factor (10 levels).}
#'   \item{year}{Survey year, a factor (4 levels).}
#' }
#' @seealso [fit_size_sim_nereo] for a fit to this dataset.
#' @family data
"data_size_sim_nereo"
