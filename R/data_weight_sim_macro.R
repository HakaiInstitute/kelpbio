#' Simulated Macrocystis Weight Dataset
#'
#' A small simulated dataset of frond count and wet weight (columns `fronds`,
#' `weight`, `site`, `year`), for fast tests and runnable examples. It is
#' simulated from the weight-model structure (Gamma response with site, year, and
#' site:year random intercepts on the log mean), not real survey data, and is not
#' intended for inference. Built by `data-raw/data_weight_sim_macro.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{fronds}{Frond count, a positive whole number.}
#'   \item{weight}{Wet weight (kg), a positive number.}
#'   \item{site}{Survey site, a factor (10 levels).}
#'   \item{year}{Survey year, a factor (4 levels).}
#' }
#' @seealso [fit_weight_sim_macro] for a fit to this dataset.
#' @family data
"data_weight_sim_macro"
