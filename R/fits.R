# Built by data-raw/fit_carbon_sim_macro.R.
#' Example Macrocystis carbon fit
#'
#' A fit of [kb_fit_carbon_macro()] to [data_carbon_sim_macro] with fewer draws
#' than the default, for exploring the fit methods without running the sampler.
#'
#' @format An object of class
#'   `c("kb_fit_carbon_macro", "kb_fit_carbon", "kb_fit")`.
#' @seealso [kb_fit_carbon_macro()] and [data_carbon_sim_macro].
#' @family example fits
"fit_carbon_sim_macro"

# Built by data-raw/fit_carbon_sim_nereo.R.
#' Example Nereocystis carbon fit
#'
#' A fit of [kb_fit_carbon_nereo()] to [data_carbon_sim_nereo] with fewer draws
#' than the default, for exploring the fit methods without running the sampler.
#'
#' @format An object of class
#'   `c("kb_fit_carbon_nereo", "kb_fit_carbon", "kb_fit")`.
#' @seealso [kb_fit_carbon_nereo()] and [data_carbon_sim_nereo].
#' @family example fits
"fit_carbon_sim_nereo"

# Built by data-raw/fit_cover_calibration_sim_macro.R.
#' Example Macrocystis cover calibration fit
#'
#' A fit of [kb_fit_cover_calibration_macro()] to the survey biomass from
#' [kb_predict_biomass_survey()] with [fit_weight_sim_macro], [data_size_census_sim_macro], and
#' [data_survey_sim_macro], with fewer draws than the default, for exploring the
#' fit methods without running the sampler.
#'
#' @format An object of class
#'   `c("kb_fit_cover_calibration_macro", "kb_fit_cover_calibration", "kb_fit")`.
#' @seealso [kb_fit_cover_calibration_macro()] and [data_survey_sim_macro].
#' @family example fits
"fit_cover_calibration_sim_macro"

# Built by data-raw/fit_cover_calibration_sim_nereo.R.
#' Example Nereocystis cover calibration fit
#'
#' A fit of [kb_fit_cover_calibration_nereo()] to the survey biomass from
#' [kb_predict_biomass_survey()] with [fit_weight_sim_nereo], [fit_size_sim_nereo], and
#' [data_survey_sim_nereo], with fewer draws than the default, for exploring the
#' fit methods without running the sampler.
#'
#' @format An object of class
#'   `c("kb_fit_cover_calibration_nereo", "kb_fit_cover_calibration", "kb_fit")`.
#' @seealso [kb_fit_cover_calibration_nereo()] and [data_survey_sim_nereo].
#' @family example fits
"fit_cover_calibration_sim_nereo"

# Built by data-raw/fit_size_sim_nereo.R.
#' Example Nereocystis size fit
#'
#' A fit of [kb_fit_size_nereo()] to [data_size_sample_sim_nereo] with fewer draws than
#' the default, for exploring the fit methods without running the sampler.
#'
#' @format An object of class `c("kb_fit_size_nereo", "kb_fit_size", "kb_fit")`.
#' @seealso [kb_fit_size_nereo()] and [data_size_sample_sim_nereo].
#' @family example fits
"fit_size_sim_nereo"

# Built by data-raw/fit_weight_sim_macro.R.
#' Example Macrocystis weight fit
#'
#' A fit of [kb_fit_weight_macro()] to [data_weight_sim_macro] with fewer draws
#' than the default, for exploring the fit methods without running the sampler.
#'
#' @format An object of class
#'   `c("kb_fit_weight_macro", "kb_fit_weight", "kb_fit")`.
#' @seealso [kb_fit_weight_macro()] and [data_weight_sim_macro].
#' @family example fits
"fit_weight_sim_macro"

# Built by data-raw/fit_weight_sim_nereo.R.
#' Example Nereocystis weight fit
#'
#' A fit of [kb_fit_weight_nereo()] to [data_weight_sim_nereo] with fewer draws
#' than the default, for exploring the fit methods without running the sampler.
#'
#' @format An object of class
#'   `c("kb_fit_weight_nereo", "kb_fit_weight", "kb_fit")`.
#' @seealso [kb_fit_weight_nereo()] and [data_weight_sim_nereo].
#' @family example fits
"fit_weight_sim_nereo"

# Built by data-raw/fit_wetdry_sim_macro.R.
#' Example Macrocystis wet/dry fit
#'
#' A fit of [kb_fit_wetdry_macro()] to [data_wetdry_sim_macro] with fewer draws
#' than the default, for exploring the fit methods without running the sampler.
#'
#' @format An object of class
#'   `c("kb_fit_wetdry_macro", "kb_fit_wetdry", "kb_fit")`.
#' @seealso [kb_fit_wetdry_macro()] and [data_wetdry_sim_macro].
#' @family example fits
"fit_wetdry_sim_macro"

# Built by data-raw/fit_wetdry_sim_nereo.R.
#' Example Nereocystis wet/dry fit
#'
#' A fit of [kb_fit_wetdry_nereo()] to [data_wetdry_sim_nereo] with fewer draws
#' than the default, for exploring the fit methods without running the sampler.
#'
#' @format An object of class
#'   `c("kb_fit_wetdry_nereo", "kb_fit_wetdry", "kb_fit")`.
#' @seealso [kb_fit_wetdry_nereo()] and [data_wetdry_sim_nereo].
#' @family example fits
"fit_wetdry_sim_nereo"

# Built by data-raw/fit_carbon_hakai_macro.R.
#' Hakai Institute Macrocystis carbon fit
#'
#' A fit of [kb_fit_carbon_macro()] to Hakai Institute tissue samples in British
#' Columbia, all months and tissues pooled, for
#' converting dry biomass to carbon without fitting a carbon model.
#'
#' @format An object of class
#'   `c("kb_fit_carbon_macro", "kb_fit_carbon", "kb_fit")`. The data are in
#'   `fit$data`.
#' @seealso [kb_fit_carbon_macro()].
#' @family reference fits
"fit_carbon_hakai_macro"

# Built by data-raw/fit_carbon_hakai_nereo.R.
#' Hakai Institute Nereocystis carbon fit
#'
#' A fit of [kb_fit_carbon_nereo()] to Hakai Institute tissue samples in British
#' Columbia, all months and tissues pooled, for
#' converting dry biomass to carbon without fitting a carbon model.
#'
#' @format An object of class
#'   `c("kb_fit_carbon_nereo", "kb_fit_carbon", "kb_fit")`. The data are in
#'   `fit$data`.
#' @seealso [kb_fit_carbon_nereo()].
#' @family reference fits
"fit_carbon_hakai_nereo"

# Built by data-raw/fit_size_hakai_nereo.R.
#' Hakai Institute Nereocystis size fit
#'
#' A fit of [kb_fit_size_nereo()] to maximum sub-bulb diameters measured in
#' Hakai Institute surveys in British Columbia.
#'
#' @format An object of class `c("kb_fit_size_nereo", "kb_fit_size", "kb_fit")`.
#'   The data are in `fit$data`.
#' @seealso [kb_fit_size_nereo()].
#' @family reference fits
"fit_size_hakai_nereo"

# Built by data-raw/fit_weight_coastwide_nereo.R.
#' Coastwide Nereocystis weight fit
#'
#' A fit of [kb_fit_weight_nereo()] to a coastwide compilation of harvested
#' plants from Alaska to California, measured at the maximum sub-bulb
#' diameter. Site names are prefixed with the contributing programme
#' (`"<programme>:<site>"`).
#'
#' @format An object of class
#'   `c("kb_fit_weight_nereo", "kb_fit_weight", "kb_fit")`. The data are in
#'   `fit$data`, with the extra columns `study` (contributing programme) and
#'   `region`.
#' @seealso [kb_fit_weight_nereo()] and [fit_weight_hakai_nereo] for the Hakai
#'   Institute harvests alone.
#' @family reference fits
"fit_weight_coastwide_nereo"

# Built by data-raw/fit_weight_hakai_macro.R.
#' Hakai Institute Macrocystis weight fit
#'
#' A fit of [kb_fit_weight_macro()] to plants harvested by the Hakai Institute
#' in British Columbia.
#'
#' @format An object of class
#'   `c("kb_fit_weight_macro", "kb_fit_weight", "kb_fit")`. The data are in
#'   `fit$data`.
#' @seealso [kb_fit_weight_macro()].
#' @family reference fits
"fit_weight_hakai_macro"

# Built by data-raw/fit_weight_hakai_nereo.R.
#' Hakai Institute Nereocystis weight fit
#'
#' A fit of [kb_fit_weight_nereo()] to plants harvested by the Hakai Institute
#' in British Columbia after day of year 140, measured at the maximum sub-bulb
#' diameter.
#'
#' @format An object of class
#'   `c("kb_fit_weight_nereo", "kb_fit_weight", "kb_fit")`. The data are in
#'   `fit$data`.
#' @seealso [kb_fit_weight_nereo()] and [fit_weight_coastwide_nereo] for the
#'   coastwide compilation.
#' @family reference fits
"fit_weight_hakai_nereo"

# Built by data-raw/fit_wetdry_hakai_macro.R.
#' Hakai Institute Macrocystis wet/dry fit
#'
#' A fit of [kb_fit_wetdry_macro()] to Hakai Institute tissue samples in British
#' Columbia, all months and tissues pooled, for
#' converting wet biomass to dry without fitting a wet/dry model.
#'
#' @format An object of class
#'   `c("kb_fit_wetdry_macro", "kb_fit_wetdry", "kb_fit")`. The data are in
#'   `fit$data`.
#' @seealso [kb_fit_wetdry_macro()].
#' @family reference fits
"fit_wetdry_hakai_macro"

# Built by data-raw/fit_wetdry_hakai_nereo.R.
#' Hakai Institute Nereocystis wet/dry fit
#'
#' A fit of [kb_fit_wetdry_nereo()] to Hakai Institute tissue samples in British
#' Columbia, all months and tissues pooled, for
#' converting wet biomass to dry without fitting a wet/dry model.
#'
#' @format An object of class
#'   `c("kb_fit_wetdry_nereo", "kb_fit_wetdry", "kb_fit")`. The data are in
#'   `fit$data`.
#' @seealso [kb_fit_wetdry_nereo()].
#' @family reference fits
"fit_wetdry_hakai_nereo"
