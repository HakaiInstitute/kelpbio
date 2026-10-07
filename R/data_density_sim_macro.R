#' Simulated Macrocystis Density Dataset
#'
#' A small simulated dataset of plant counts on transects (columns `plants`,
#' `area_m2`, `site`, `year`), one row per transect, for fast tests and runnable
#' examples. It is one of five *Macrocystis* datasets simulated together from
#' the same ten sites, four years, and true site-year values, with parameters
#' near those estimated from Hakai Institute surveys, so plot biomass composed
#' from fits to the weight, size, and density datasets agrees with
#' [data_plot_biomass_sim_macro]. Transects were surveyed at every site-year but
#' two. The site names are invented. The data are not real survey data and are
#' not intended for inference. Built by `data-raw/data_sim_macro.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{plants}{Number of plants counted on the transect, a whole number of at
#'     least 0.}
#'   \item{area_m2}{Area surveyed (m²), a positive number.}
#'   \item{site}{Survey site, a factor (10 levels, invented names).}
#'   \item{year}{Survey year, a factor (4 levels).}
#' }
#' @seealso [fit_density_sim_macro] for a fit to this dataset.
#' @family data
"data_density_sim_macro"
