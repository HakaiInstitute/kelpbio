#' Fit a Nereocystis cover calibration model
#'
#' Fit a calibration of in situ survey biomass on drone canopy cover for
#' *Nereocystis luetkeana* via Stan.
#'
#' @details
#' `data` is the output of [kb_predict_biomass_in_situ()] with its defaults: wet
#' biomass per m² of each in situ survey, with the survey's drone cover on its
#' row. Each survey with drone cover is one observation; surveys without it
#' are not fitted, and a message gives their number. The calibration takes each
#' survey's biomass per m² as that of its plot.
#'
#' A survey's mean wet biomass (kg/m²) is modelled with a Normal likelihood
#' censored below at zero, so a survey with no plants counted enters as the
#' probability of zero or less. Its mean is `mu = biomass_floor + cover_slope *
#' exp(site_effect + year_effect) * cover`: `cover_slope` is the wet biomass per
#' m² of canopy at a typical site and year, and `biomass_floor`, common to all
#' sites and years, the wet biomass of a plot with no delineated canopy. Its SD
#' is `sqrt(sd_residual^2 + (cv_residual * mu)^2 + biomass_sd^2)`, where
#' `biomass_sd` is the SD of the survey's biomass draws, from plant weight.
#'
#' `cover` is `canopy_area_m2 / (1 - tide_height_slope * canopy_tide_height_m)` over
#' the plot area, capped at 1 (Timmer et al. 2024); a survey with canopy at a
#' tide height at or above `1 / tide_height_slope` is fully covered, and the fit
#' warns when that holds with more than 5% prior probability. The default prior
#' on `tide_height_slope` largely sets the correction: raise its mean for beds in
#' strong current. Imagery at a tide of 2 m or below follows published practice and stays
#' below the tide limit. Pass canopy already corrected for tide with
#' `canopy_tide_height_m = 0`.
#'
#' @inheritSection params Sampling
#' @inheritParams kb_fit_weight_nereo
#' @inheritParams params
#' @param data A data frame of in situ survey biomass with drone cover, one row
#'   per survey (see [kb_check_data_cover_calibration_nereo()] for the columns).
#' @param priors A named list of prior objects (see
#'   [kb_priors_cover_calibration_nereo()]), or `NULL` to use the defaults.
#'   Entries not supplied keep their defaults.
#'
#' @returns A `kb_fit_cover_calibration_nereo` object (a `kb_fit`). Its `data`
#'   holds the fitted surveys, with `biomass_kg_m2` the mean of each survey's
#'   draws and `biomass_sd_kg_m2` their SD.
#' @references Timmer, B., Reshitnyk, L. Y., Hessing-Lewis, M., Juanes, F.,
#'   Gendall, L., and Costa, M. (2024). Capturing accurate kelp canopy extent:
#'   integrating tides, currents, and species-level morphology in kelp remote
#'   sensing. *Frontiers in Environmental Science*, 12, 1338483.
#'   \doi{10.3389/fenvs.2024.1338483}
#' @family fit functions
#' @export
#'
#' @examples
#' # A pre-fit example model is included with the package:
#' tidy(fit_cover_calibration_sim_nereo)
#' @examplesIf interactive()
#' biomass <- kb_predict_biomass_in_situ(
#'   fit_weight_sim_nereo,
#'   fit_size_sim_nereo,
#'   data_in_situ_sim_nereo
#' )
#' fit <- kb_fit_cover_calibration_nereo(biomass)
#' tidy(fit)
kb_fit_cover_calibration_nereo <- function(
  data,
  priors = NULL,
  ...,
  prior_only = FALSE,
  chains = 4L,
  niters = 1000L,
  nthin = 1L,
  cores = NULL,
  seed = NULL,
  progress = c("bar", "verbose", "none"),
  progress_dir = NULL
) {
  fit_cover_calibration_model(
    data,
    priors,
    species = "nereocystis",
    check_data = kb_check_data_cover_calibration_nereo,
    defaults = kb_priors_cover_calibration_nereo(),
    ...,
    prior_only = prior_only,
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir
  )
}
