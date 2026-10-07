#' Simulated Macrocystis Weight Dataset
#'
#' A small simulated dataset of frond count and wet weight (columns `fronds`,
#' `weight_kg`, `site`, `year`), one row per harvested plant, for fast tests and
#' runnable examples. It is one of five *Macrocystis* datasets simulated
#' together from the same ten sites, four years, and true site-year values, with
#' parameters near those estimated from Hakai Institute surveys, so plot biomass
#' composed from fits to the weight, size, and density datasets agrees with
#' [data_plot_biomass_sim_macro]. Plants were harvested at about half of the
#' density-surveyed site-years, and three sites were never harvested. The site
#' names are invented. The data are not real survey data and are not intended
#' for inference. Built by `data-raw/data_sim_macro.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{fronds}{Frond count, a positive whole number.}
#'   \item{weight_kg}{Wet weight (kg), a positive number.}
#'   \item{site}{Survey site, a factor (10 levels, invented names).}
#'   \item{year}{Survey year, a factor (4 levels).}
#' }
#' @seealso [fit_weight_sim_macro] for a fit to this dataset.
#' @family data
"data_weight_sim_macro"
