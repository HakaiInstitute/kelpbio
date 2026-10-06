#' Simulated Macrocystis In Situ Biomass for the Cover Biomass Model
#'
#' A small simulated dataset of the in situ wet biomass of each site-year in
#' [data_cover_biomass_sim_macro] (columns `site`, `year`, `estimate`, `lower`,
#' `upper`), one row per site-year, standing in for the output of a biomass
#' prediction, for fast tests and runnable examples. It is simulated from the
#' cover biomass model structure, not real survey data, and is not intended for
#' inference. Built by `data-raw/data_cover_biomass_sim_macro.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{site}{Survey site, a factor (10 levels).}
#'   \item{year}{Survey year, a factor (4 levels).}
#'   \item{estimate}{In situ wet biomass (kg/m²), a positive number.}
#'   \item{lower, upper}{Lower and upper 95% compatibility limits of
#'     `estimate` (kg/m²).}
#' }
#' @seealso [fit_cover_biomass_sim_macro] for a fit to this dataset.
#' @family data
"data_plot_biomass_sim_macro"
