# Built by data-raw/data_carbon_sim_macro.R.
#' Simulated Macrocystis carbon data
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
#' @family example datasets
"data_carbon_sim_macro"

# Built by data-raw/data_carbon_sim_nereo.R.
#' Simulated Nereocystis carbon data
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
#' @family example datasets
"data_carbon_sim_nereo"

# Built by data-raw/data_sim_nereo.R.
#' Simulated Nereocystis size sample data
#'
#' A small simulated dataset of maximum sub-bulb diameter, one row per plant of
#' a sample measured for the size model, for runnable examples. One of four
#' simulated *Nereocystis* datasets with shared sites and years, so their fits
#' can be combined into in situ survey biomass (see [kb_predict_biomass_in_situ()]). Some
#' site-years have no size data.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{diameter_mm}{Maximum sub-bulb diameter (mm), a positive number.}
#'   \item{site}{Site, a factor (12 levels).}
#'   \item{year}{Year, a factor (5 levels).}
#' }
#' @seealso [fit_size_sim_nereo] for a fit to this dataset.
#' @family example datasets
"data_size_sample_sim_nereo"

# Built by data-raw/data_sim_macro.R.
#' Simulated Macrocystis weight data
#'
#' A small simulated dataset of frond count and wet weight, one row per
#' harvested plant, for runnable examples. One of four simulated *Macrocystis*
#' datasets with shared sites and years, so their fits can be combined into
#' survey biomass (see [kb_predict_biomass_in_situ()]). Some site-years have no
#' weight data.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{fronds}{Fronds reaching 1 m above the holdfast, a positive whole
#'     number.}
#'   \item{weight_kg}{Wet weight (kg), a positive number.}
#'   \item{site}{Site, a factor (12 levels).}
#'   \item{year}{Harvest year, a factor (5 levels).}
#' }
#' @seealso [fit_weight_sim_macro] for a fit to this dataset.
#' @family example datasets
"data_weight_sim_macro"

# Built by data-raw/data_sim_nereo.R.
#' Simulated Nereocystis weight data
#'
#' A small simulated dataset of sub-bulb diameter and wet weight, one row per
#' harvested plant, for runnable examples. One of four simulated *Nereocystis*
#' datasets with shared sites and years, so their fits can be combined into
#' survey biomass (see [kb_predict_biomass_in_situ()]). Some site-years have no
#' weight data.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{diameter_mm}{Sub-bulb diameter (mm), a positive number.}
#'   \item{weight_kg}{Wet weight (kg), a positive number.}
#'   \item{site}{Site, a factor (12 levels).}
#'   \item{year}{Harvest year, a factor (5 levels).}
#' }
#' @seealso [fit_weight_sim_nereo] for a fit to this dataset.
#' @family example datasets
"data_weight_sim_nereo"

# Built by data-raw/data_wetdry_sim_macro.R.
#' Simulated Macrocystis wet/dry data
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
#' @family example datasets
"data_wetdry_sim_macro"

# Built by data-raw/data_wetdry_sim_nereo.R.
#' Simulated Nereocystis wet/dry data
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
#' @family example datasets
"data_wetdry_sim_nereo"

# Built by data-raw/data_sim_nereo.R.
#' Simulated Nereocystis in situ survey data
#'
#' A small simulated dataset of in situ surveys, one row per survey,
#' for runnable examples: the plants tallied, with sizes from
#' [fit_size_sim_nereo], and the drone cover of the surveys paired with a
#' flight. Some site-years hold more than one survey, and one survey counted no
#' plants.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{survey_id}{Survey identifier, a character string.}
#'   \item{site}{Site, a factor (12 levels).}
#'   \item{year}{Year, a factor (5 levels).}
#'   \item{survey_area_m2}{Surveyed area (m²), a positive number.}
#'   \item{plants}{Plants counted, a whole number of at least 0.}
#'   \item{plot_area_m2}{Plot polygon (m²), or `NA` without a flight.}
#'   \item{canopy_area_m2}{Drone canopy within the plot (m²), or `NA` without
#'     a flight.}
#'   \item{tide_height_m}{Tide height at the flight (m), or `NA` without a
#'     flight.}
#' }
#' @seealso [kb_check_data_in_situ()] for the columns.
#' @family example datasets
"data_in_situ_sim_nereo"

# Built by data-raw/data_sim_nereo.R.
#' Simulated Nereocystis canopy data
#'
#' A small simulated dataset of drone-mapped canopy, one row per map of a
#' site's canopy, for runnable examples of totals over the canopy.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{site}{Site, a factor (12 levels).}
#'   \item{year}{Year, a factor (5 levels).}
#'   \item{canopy_area_m2}{Canopy mapped within the site (m²).}
#'   \item{tide_height_m}{Tide height at the flight (m).}
#'   \item{classified_area_m2}{Water area the canopy classification covered
#'     (m²), including water with no canopy.}
#'   \item{region}{Region of the site, a factor (`"north"`, `"south"`).}
#' }
#' @seealso [kb_predict_biomass_canopy()].
#' @family example datasets
"data_canopy_sim_nereo"

# Built by data-raw/data_sim_macro.R.
#' Simulated Macrocystis in situ survey data
#'
#' A small simulated dataset of in situ surveys, one row per survey,
#' for runnable examples: the plants listed in [data_size_census_sim_macro], and the
#' drone cover of the surveys paired with a flight. Some site-years hold more
#' than one survey, and one survey counted no plants.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{survey_id}{Survey identifier, a character string.}
#'   \item{site}{Site, a factor (12 levels).}
#'   \item{year}{Year, a factor (5 levels).}
#'   \item{survey_area_m2}{Surveyed area (m²), a positive number.}
#'   \item{plot_area_m2}{Plot polygon (m²), or `NA` without a flight.}
#'   \item{canopy_area_m2}{Drone canopy within the plot (m²), or `NA` without
#'     a flight.}
#'   \item{tide_height_m}{Tide height at the flight (m), or `NA` without a
#'     flight.}
#' }
#' @seealso [kb_check_data_in_situ()] for the columns.
#' @family example datasets
"data_in_situ_sim_macro"

# Built by data-raw/data_sim_macro.R.
#' Simulated Macrocystis canopy data
#'
#' A small simulated dataset of drone-mapped canopy, one row per map of a
#' site's canopy, for runnable examples of totals over the canopy.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{site}{Site, a factor (12 levels).}
#'   \item{year}{Year, a factor (5 levels).}
#'   \item{canopy_area_m2}{Canopy mapped within the site (m²).}
#'   \item{tide_height_m}{Tide height at the flight (m).}
#'   \item{classified_area_m2}{Water area the canopy classification covered
#'     (m²), including water with no canopy.}
#'   \item{region}{Region of the site, a factor (`"north"`, `"south"`).}
#' }
#' @seealso [kb_predict_biomass_canopy()].
#' @family example datasets
"data_canopy_sim_macro"

# Built by data-raw/data_sim_macro.R.
#' Simulated Macrocystis size census data
#'
#' A small simulated dataset of every plant counted by the surveys in
#' [data_in_situ_sim_macro], one row per plant, for runnable examples.
#'
#' @format A data frame with columns:
#' \describe{
#'   \item{survey_id}{Survey the plant was counted in, matching its
#'     `survey_id`.}
#'   \item{fronds}{Fronds reaching 1 m above the holdfast, a positive whole
#'     number.}
#'   \item{partial}{Whether the plant is counted as half, a logical.}
#' }
#' @seealso [kb_check_data_size_census_macro()] for the columns.
#' @family example datasets
"data_size_census_sim_macro"
