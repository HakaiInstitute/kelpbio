#' Simulated Macrocystis Carbon Dataset
#'
#' A small simulated dataset of sample and carbon masses (columns
#' `sample_mass_mg`, `carbon_mass_ug`), one row per dried tissue sample, for fast
#' tests and runnable examples. It is simulated from the carbon model structure (a
#' Beta carbon fraction with a mean and precision common to all samples), not real
#' lab data, and is not intended for inference. Built by
#' `data-raw/data_carbon_sim_macro.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{sample_mass_mg}{Mass of the dried sample analysed (mg), a positive
#'     number.}
#'   \item{carbon_mass_ug}{Carbon measured in the sample (µg), a positive number
#'     less than the sample mass.}
#' }
#' @seealso [fit_carbon_sim_macro] for a fit to this dataset.
#' @family data
"data_carbon_sim_macro"

#' Simulated Nereocystis Carbon Dataset
#'
#' A small simulated dataset of sample and carbon masses (columns
#' `sample_mass_mg`, `carbon_mass_ug`), one row per dried tissue sample, for fast
#' tests and runnable examples. It is simulated from the carbon model structure (a
#' Beta carbon fraction with a mean and precision common to all samples), not real
#' lab data, and is not intended for inference. Built by
#' `data-raw/data_carbon_sim_nereo.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{sample_mass_mg}{Mass of the dried sample analysed (mg), a positive
#'     number.}
#'   \item{carbon_mass_ug}{Carbon measured in the sample (µg), a positive number
#'     less than the sample mass.}
#' }
#' @seealso [fit_carbon_sim_nereo] for a fit to this dataset.
#' @family data
"data_carbon_sim_nereo"

#' Simulated Macrocystis Cover Dataset
#'
#' A small simulated dataset of drone surveys (columns `site`, `year`,
#' `canopy_area_m2`, `plot_area_m2`, `tide_height_m`), one row per survey, for
#' fast tests and runnable examples, paired with the in situ biomass in
#' [data_plot_biomass_sim_macro]. It is one of five *Macrocystis* datasets
#' simulated together from the same ten sites, four years, and true site-year
#' values, with parameters near those estimated from Hakai Institute surveys, so
#' plot biomass composed from fits to the weight, size, and density datasets
#' agrees with [data_plot_biomass_sim_macro]. Surveys cover about two-thirds of
#' the density-surveyed site-years, one survey each. The site names are
#' invented. The data are not real survey data and are not intended for
#' inference. Built by `data-raw/data_sim_macro.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{site}{Survey site, a factor (10 levels, invented names).}
#'   \item{year}{Survey year, a factor (4 levels).}
#'   \item{canopy_area_m2}{Canopy area delineated within the plot (m²), at
#'     least 0.}
#'   \item{plot_area_m2}{Plot area (m²), a positive number.}
#'   \item{tide_height_m}{Tide height at the survey (m, chart datum).}
#' }
#' @seealso [fit_cover_biomass_sim_macro] for a fit to this dataset.
#' @family data
"data_cover_biomass_sim_macro"

#' Simulated Nereocystis Cover Dataset
#'
#' A small simulated dataset of drone surveys (columns `site`, `year`,
#' `canopy_area_m2`, `plot_area_m2`, `tide_height_m`), one row per survey, for
#' fast tests and runnable examples, paired with the in situ biomass in
#' [data_plot_biomass_sim_nereo]. It is one of five *Nereocystis* datasets
#' simulated together from the same ten sites, four years, and true site-year
#' values, with parameters near those estimated from Hakai Institute surveys, so
#' plot biomass composed from fits to the weight, size, and density datasets
#' agrees with [data_plot_biomass_sim_nereo]. Surveys cover about two-thirds of
#' the density-surveyed site-years, one survey each. The site names are
#' invented. The data are not real survey data and are not intended for
#' inference. Built by `data-raw/data_sim_nereo.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{site}{Survey site, a factor (10 levels, invented names).}
#'   \item{year}{Survey year, a factor (4 levels).}
#'   \item{canopy_area_m2}{Canopy area delineated within the plot (m²), at
#'     least 0.}
#'   \item{plot_area_m2}{Plot area (m²), a positive number.}
#'   \item{tide_height_m}{Tide height at the survey (m, chart datum).}
#' }
#' @seealso [fit_cover_biomass_sim_nereo] for a fit to this dataset.
#' @family data
"data_cover_biomass_sim_nereo"

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

#' Simulated Nereocystis Density Dataset
#'
#' A small simulated dataset of stipe counts on transects (columns `stipes`,
#' `area_m2`, `site`, `year`), one row per transect, for fast tests and runnable
#' examples. It is one of five *Nereocystis* datasets simulated together from
#' the same ten sites, four years, and true site-year values, with parameters
#' near those estimated from Hakai Institute surveys, so plot biomass composed
#' from fits to the weight, size, and density datasets agrees with
#' [data_plot_biomass_sim_nereo]. Transects were surveyed at every site-year but
#' two. The site names are invented. The data are not real survey data and are
#' not intended for inference. Built by `data-raw/data_sim_nereo.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{stipes}{Number of stipes counted on the transect, a whole number of at
#'     least 0.}
#'   \item{area_m2}{Area surveyed (m²), a positive number.}
#'   \item{site}{Survey site, a factor (10 levels, invented names).}
#'   \item{year}{Survey year, a factor (4 levels).}
#' }
#' @seealso [fit_density_sim_nereo] for a fit to this dataset.
#' @family data
"data_density_sim_nereo"

#' Simulated Macrocystis In Situ Biomass for the Cover Biomass Model
#'
#' A small simulated dataset of the in situ wet biomass of each site-year in
#' [data_cover_biomass_sim_macro] (columns `site`, `year`, `estimate`, `lower`,
#' `upper`), one row per site-year, standing in for the output of
#' [kb_predict_plot_biomass()], for fast tests and runnable examples. It is one
#' of five *Macrocystis* datasets simulated together from the same ten sites,
#' four years, and true site-year values, with parameters near those estimated
#' from Hakai Institute surveys, so plot biomass composed from fits to the
#' weight, size, and density datasets agrees with these estimates. Each estimate
#' is the true plot biomass of its site-year with lognormal estimation error,
#' which its limits understate slightly, as the cover biomass model allows for.
#' The site names are invented. The data are not real survey data and are not
#' intended for inference. Built by `data-raw/data_sim_macro.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{site}{Survey site, a factor (10 levels, invented names).}
#'   \item{year}{Survey year, a factor (4 levels).}
#'   \item{estimate}{In situ wet biomass (kg/m²), a positive number.}
#'   \item{lower, upper}{Lower and upper 95% compatibility limits of
#'     `estimate` (kg/m²).}
#' }
#' @seealso [fit_cover_biomass_sim_macro] for a fit to this dataset.
#' @family data
"data_plot_biomass_sim_macro"

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

#' Simulated Macrocystis Size Dataset
#'
#' A small simulated dataset of frond counts (columns `fronds`, `site`, `year`),
#' one row per plant, for fast tests and runnable examples. It is one of five
#' *Macrocystis* datasets simulated together from the same ten sites, four
#' years, and true site-year values, with parameters near those estimated from
#' Hakai Institute surveys, so plot biomass composed from fits to the weight,
#' size, and density datasets agrees with [data_plot_biomass_sim_macro]. Plants
#' were measured at most density-surveyed site-years; a few have no size data.
#' The site names are invented. The data are not real survey data and are not
#' intended for inference. Built by `data-raw/data_sim_macro.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{fronds}{Number of fronds reaching 1 m above the holdfast, a positive
#'     whole number.}
#'   \item{site}{Survey site, a factor (10 levels, invented names).}
#'   \item{year}{Survey year, a factor (4 levels).}
#' }
#' @seealso [fit_size_sim_macro] for a fit to this dataset.
#' @family data
"data_size_sim_macro"

#' Simulated Nereocystis Size Dataset
#'
#' A small simulated dataset of maximum sub-bulb diameter (columns
#' `diameter_mm`, `site`, `year`), one row per plant, for fast tests and
#' runnable examples. It is one of five *Nereocystis* datasets simulated
#' together from the same ten sites, four years, and true site-year values, with
#' parameters near those estimated from Hakai Institute surveys, so plot biomass
#' composed from fits to the weight, size, and density datasets agrees with
#' [data_plot_biomass_sim_nereo]. Plants were measured at most density-surveyed
#' site-years; a few have no size data. The site names are invented. The data
#' are not real survey data and are not intended for inference. Built by
#' `data-raw/data_sim_nereo.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{diameter_mm}{Maximum sub-bulb diameter (mm), a positive number.}
#'   \item{site}{Survey site, a factor (10 levels, invented names).}
#'   \item{year}{Survey year, a factor (4 levels).}
#' }
#' @seealso [fit_size_sim_nereo] for a fit to this dataset.
#' @family data
"data_size_sim_nereo"

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

#' Simulated Macrocystis Wet/Dry Dataset
#'
#' A small simulated dataset of sample wet and dry masses (columns `wet_mass_g`,
#' `dry_mass_g`), one row per tissue sample, for fast tests and runnable examples.
#' It is simulated from the wet/dry model structure (a Beta dry:wet mass ratio with
#' a mean and precision common to all samples), not real lab data, and is not
#' intended for inference. Built by `data-raw/data_wetdry_sim_macro.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{wet_mass_g}{Wet mass of the sample (g), a positive number.}
#'   \item{dry_mass_g}{Dry mass of the sample (g), a positive number less than
#'     `wet_mass_g`.}
#' }
#' @seealso [fit_wetdry_sim_macro] for a fit to this dataset.
#' @family data
"data_wetdry_sim_macro"

#' Simulated Nereocystis Wet/Dry Dataset
#'
#' A small simulated dataset of sample wet and dry masses (columns `wet_mass_g`,
#' `dry_mass_g`), one row per tissue sample, for fast tests and runnable examples.
#' It is simulated from the wet/dry model structure (a Beta dry:wet mass ratio with
#' a mean and precision common to all samples), not real lab data, and is not
#' intended for inference. Built by `data-raw/data_wetdry_sim_nereo.R`.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{wet_mass_g}{Wet mass of the sample (g), a positive number.}
#'   \item{dry_mass_g}{Dry mass of the sample (g), a positive number less than
#'     `wet_mass_g`.}
#' }
#' @seealso [fit_wetdry_sim_nereo] for a fit to this dataset.
#' @family data
"data_wetdry_sim_nereo"
