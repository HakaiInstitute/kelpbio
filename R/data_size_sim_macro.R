#' Simulated Macrocystis Size Dataset
#'
#' A small simulated dataset of frond counts (columns `fronds`, `site`, `year`),
#' one row per plant, for fast tests and runnable examples. It is simulated from
#' the size-model structure (a zero-truncated negative binomial with site, year,
#' and site:year effects on the log mean), not real survey data, and is not
#' intended for inference. Built by `data-raw/data_size_sim_macro.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{fronds}{Number of fronds reaching 1 m above the holdfast, a positive
#'     whole number.}
#'   \item{site}{Survey site, a factor (10 levels).}
#'   \item{year}{Survey year, a factor (4 levels).}
#' }
#' @seealso [fit_size_sim_macro] for a fit to this dataset.
#' @family data
"data_size_sim_macro"
