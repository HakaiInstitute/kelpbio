#' Simulated Nereocystis Cover Dataset
#'
#' A small simulated dataset of drone surveys (columns `site`, `year`,
#' `canopy_area_m2`, `plot_area_m2`, `tide_height_m`), one row per survey, for
#' fast tests and runnable examples. Paired with the in situ biomass in
#' [data_plot_biomass_sim_nereo]. It is simulated from the cover biomass model structure
#' (a biomass floor plus a canopy term proportional to tide-corrected cover, with
#' site and year effects on the canopy term), not real survey data, and is not
#' intended for inference. Built by `data-raw/data_cover_biomass_sim_nereo.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{site}{Survey site, a factor (10 levels).}
#'   \item{year}{Survey year, a factor (4 levels).}
#'   \item{canopy_area_m2}{Canopy area delineated within the plot (m²), at
#'     least 0.}
#'   \item{plot_area_m2}{Plot area (m²), a positive number.}
#'   \item{tide_height_m}{Tide height at the survey (m, chart datum).}
#' }
#' @seealso [fit_cover_biomass_sim_nereo] for a fit to this dataset.
#' @family data
"data_cover_biomass_sim_nereo"
