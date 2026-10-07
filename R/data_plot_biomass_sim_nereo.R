#' Simulated Nereocystis In Situ Biomass for the Cover Biomass Model
#'
#' A small simulated dataset of the in situ wet biomass of each site-year in
#' [data_cover_biomass_sim_nereo] (columns `site`, `year`, `estimate`, `lower`,
#' `upper`), one row per site-year, standing in for the output of
#' [kb_predict_plot_biomass()], for fast tests and runnable examples. It is one
#' of five *Nereocystis* datasets simulated together from the same ten sites,
#' four years, and true site-year values, with parameters near those estimated
#' from Hakai Institute surveys, so plot biomass composed from fits to the
#' weight, size, and density datasets agrees with these estimates. Each estimate
#' is the true plot biomass of its site-year with lognormal estimation error,
#' which its limits understate slightly, as the cover biomass model allows for.
#' The site names are invented. The data are not real survey data and are not
#' intended for inference. Built by `data-raw/data_sim_nereo.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{site}{Survey site, a factor (10 levels, invented names).}
#'   \item{year}{Survey year, a factor (4 levels).}
#'   \item{estimate}{In situ wet biomass (kg/m²), a positive number.}
#'   \item{lower, upper}{Lower and upper 95% compatibility limits of
#'     `estimate` (kg/m²).}
#' }
#' @seealso [fit_cover_biomass_sim_nereo] for a fit to this dataset.
#' @family data
"data_plot_biomass_sim_nereo"
