# Built by data-raw/data_carbon_sim_macro.R.
#' Simulated Macrocystis Carbon Dataset
#'
#' A small simulated dataset of sample and carbon masses, one row per dried
#' tissue sample, for runnable examples.
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

# Built by data-raw/data_carbon_sim_nereo.R.
#' Simulated Nereocystis Carbon Dataset
#'
#' A small simulated dataset of sample and carbon masses, one row per dried
#' tissue sample, for runnable examples.
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

# Built by data-raw/data_sim_macro.R.
#' Simulated Macrocystis Cover Dataset
#'
#' A small simulated dataset of drone surveys, one row per survey, for runnable
#' examples, paired with the in situ biomass in [data_plot_biomass_sim_macro]
#' to fit [kb_fit_cover_biomass_macro()]. One of five simulated *Macrocystis*
#' datasets with shared sites and years. Some site-years have no survey.
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
#' @seealso [fit_cover_biomass_sim_macro] for a fit to this dataset.
#' @family data
"data_cover_biomass_sim_macro"

# Built by data-raw/data_sim_nereo.R.
#' Simulated Nereocystis Cover Dataset
#'
#' A small simulated dataset of drone surveys, one row per survey, for runnable
#' examples, paired with the in situ biomass in [data_plot_biomass_sim_nereo]
#' to fit [kb_fit_cover_biomass_nereo()]. One of five simulated *Nereocystis*
#' datasets with shared sites and years. Some site-years have no survey.
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

# Built by data-raw/data_sim_macro.R.
#' Simulated Macrocystis Density Dataset
#'
#' A small simulated dataset of plant counts on transects, one row per
#' transect, for runnable examples. One of five simulated *Macrocystis*
#' datasets with shared sites and years, so their fits can be combined into
#' plot biomass (see [kb_predict_plot_biomass()]).
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{plants}{Number of plants with at least one frond reaching 1 m above
#'     the holdfast counted on the transect, a whole number of at least 0.}
#'   \item{area_m2}{Area surveyed (m²), a positive number.}
#'   \item{site}{Survey site, a factor (10 levels).}
#'   \item{year}{Survey year, a factor (4 levels).}
#' }
#' @seealso [fit_density_sim_macro] for a fit to this dataset.
#' @family data
"data_density_sim_macro"

# Built by data-raw/data_sim_nereo.R.
#' Simulated Nereocystis Density Dataset
#'
#' A small simulated dataset of stipe counts on transects, one row per
#' transect, for runnable examples. One of five simulated *Nereocystis*
#' datasets with shared sites and years, so their fits can be combined into
#' plot biomass (see [kb_predict_plot_biomass()]).
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{stipes}{Number of stipes counted on the transect, a whole number of
#'     at least 0.}
#'   \item{area_m2}{Area surveyed (m²), a positive number.}
#'   \item{site}{Survey site, a factor (10 levels).}
#'   \item{year}{Survey year, a factor (4 levels).}
#' }
#' @seealso [fit_density_sim_nereo] for a fit to this dataset.
#' @family data
"data_density_sim_nereo"

# Built by data-raw/data_sim_macro.R.
#' Simulated Macrocystis In Situ Biomass for the Cover Biomass Model
#'
#' A small simulated dataset of the in situ wet biomass of each site-year in
#' [data_cover_biomass_sim_macro], one row per site-year, in the format
#' returned by [kb_predict_plot_biomass()], for runnable examples. One of five
#' simulated *Macrocystis* datasets with shared sites and years.
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

# Built by data-raw/data_sim_nereo.R.
#' Simulated Nereocystis In Situ Biomass for the Cover Biomass Model
#'
#' A small simulated dataset of the in situ wet biomass of each site-year in
#' [data_cover_biomass_sim_nereo], one row per site-year, in the format
#' returned by [kb_predict_plot_biomass()], for runnable examples. One of five
#' simulated *Nereocystis* datasets with shared sites and years.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{site}{Survey site, a factor (10 levels).}
#'   \item{year}{Survey year, a factor (4 levels).}
#'   \item{estimate}{In situ wet biomass (kg/m²), a positive number.}
#'   \item{lower, upper}{Lower and upper 95% compatibility limits of
#'     `estimate` (kg/m²).}
#' }
#' @seealso [fit_cover_biomass_sim_nereo] for a fit to this dataset.
#' @family data
"data_plot_biomass_sim_nereo"

# Built by data-raw/data_sim_macro.R.
#' Simulated Macrocystis Size Dataset
#'
#' A small simulated dataset of frond counts, one row per plant, for runnable
#' examples. One of five simulated *Macrocystis* datasets with shared sites and
#' years, so their fits can be combined into plot biomass (see
#' [kb_predict_plot_biomass()]). Some site-years have no size data.
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

# Built by data-raw/data_sim_nereo.R.
#' Simulated Nereocystis Size Dataset
#'
#' A small simulated dataset of maximum sub-bulb diameter, one row per plant,
#' for runnable examples. One of five simulated *Nereocystis* datasets with
#' shared sites and years, so their fits can be combined into plot biomass (see
#' [kb_predict_plot_biomass()]). Some site-years have no size data.
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

# Built by data-raw/data_sim_macro.R.
#' Simulated Macrocystis Weight Dataset
#'
#' A small simulated dataset of frond count and wet weight, one row per
#' harvested plant, for runnable examples. One of five simulated *Macrocystis*
#' datasets with shared sites and years, so their fits can be combined into
#' plot biomass (see [kb_predict_plot_biomass()]). Some site-years have no
#' weight data.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{fronds}{Frond count, a positive whole number.}
#'   \item{weight_kg}{Wet weight (kg), a positive number.}
#'   \item{site}{Survey site, a factor (10 levels).}
#'   \item{year}{Survey year, a factor (4 levels).}
#' }
#' @seealso [fit_weight_sim_macro] for a fit to this dataset.
#' @family data
"data_weight_sim_macro"

# Built by data-raw/data_sim_nereo.R.
#' Simulated Nereocystis Weight Dataset
#'
#' A small simulated dataset of sub-bulb diameter, wet weight, and stipe
#' density, one row per harvested plant, for runnable examples. One of five
#' simulated *Nereocystis* datasets with shared sites and years, so their fits
#' can be combined into plot biomass (see [kb_predict_plot_biomass()]). Some
#' site-years have no weight data.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{diameter_mm}{Sub-bulb diameter (mm), a positive number.}
#'   \item{weight_kg}{Wet weight (kg), a positive number.}
#'   \item{site}{Survey site, a factor (10 levels).}
#'   \item{year}{Survey year, a factor (4 levels).}
#'   \item{stipes_m2}{Stipe density of the site-year (stipes per m²), as
#'     observed in [data_density_sim_nereo].}
#' }
#' @seealso [fit_weight_sim_nereo] for a fit to this dataset.
#' @family data
"data_weight_sim_nereo"

# Built by data-raw/data_wetdry_sim_macro.R.
#' Simulated Macrocystis Wet/Dry Dataset
#'
#' A small simulated dataset of sample wet and dry masses, one row per tissue
#' sample, for runnable examples.
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

# Built by data-raw/data_wetdry_sim_nereo.R.
#' Simulated Nereocystis Wet/Dry Dataset
#'
#' A small simulated dataset of sample wet and dry masses, one row per tissue
#' sample, for runnable examples.
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
