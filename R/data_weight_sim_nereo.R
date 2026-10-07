#' Simulated Nereocystis Weight Dataset
#'
#' A small simulated dataset of sub-bulb diameter, wet weight, and stipe density
#' (columns `diameter_mm`, `weight_kg`, `site`, `year`, `stipes_m2`), one row
#' per harvested plant, for fast tests and runnable examples. It is one of five
#' *Nereocystis* datasets simulated together from the same ten sites, four
#' years, and true site-year values, with parameters near those estimated from
#' Hakai Institute surveys, so plot biomass composed from fits to the weight,
#' size, and density datasets agrees with [data_plot_biomass_sim_nereo]. Plants
#' were harvested at about half of the density-surveyed site-years, and three
#' sites were never harvested. `stipes_m2` is the site-year's stipe density
#' observed in [data_density_sim_nereo]. The site names are invented. The data
#' are not real survey data and are not intended for inference. Built by
#' `data-raw/data_sim_nereo.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{diameter_mm}{Sub-bulb diameter (mm), a positive number.}
#'   \item{weight_kg}{Wet weight (kg), a positive number.}
#'   \item{site}{Survey site, a factor (10 levels, invented names).}
#'   \item{year}{Survey year, a factor (4 levels).}
#'   \item{stipes_m2}{Stipe density of the site-year (stipes per m²).}
#' }
#' @seealso [fit_weight_sim_nereo] for a fit to this dataset.
#' @family data
"data_weight_sim_nereo"
