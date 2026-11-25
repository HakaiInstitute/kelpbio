#' Default priors for the Nereocystis cover calibration model
#'
#' The default priors for the *Nereocystis luetkeana* cover calibration model,
#' for the `priors` argument of [kb_fit_cover_calibration_nereo()].
#'
#' The `tide_height_slope` prior, the share of canopy lost per metre of tide,
#' is informative and from Timmer et al. (2024); the calibration data do not
#' inform it. The presence priors apply only when the data hold a survey with
#' no plants counted.
#'
#' @inheritSection params Priors
#' @returns A named list of prior objects, one per parameter.
#' @references
#' Timmer, B., Reshitnyk, L. Y., Hessing-Lewis, M., Juanes, F., Gendall, L.,
#' and Costa, M. (2024). Capturing accurate kelp canopy extent: integrating
#' tides, currents, and species-level morphology in kelp remote sensing.
#' Frontiers in Environmental Science, 12, 1338483.
#' \doi{10.3389/fenvs.2024.1338483}
#' @family priors
#' @export
#'
#' @examples
#' kb_priors_cover_calibration_nereo()
#' @examplesIf interactive()
#' # Change one prior; the others keep their defaults:
#' biomass <- kb_predict_biomass_in_situ(
#'   fit_weight_sim_nereo,
#'   fit_size_sim_nereo,
#'   data_survey_in_situ_sim_nereo
#' )
#' kb_fit_cover_calibration_nereo(
#'   biomass,
#'   priors = list(cover_slope = kb_prior_lognormal(meanlog = 2, sdlog = 0.5))
#' )
kb_priors_cover_calibration_nereo <- function() {
  list(
    cover_slope = kb_prior_lognormal(meanlog = 2, sdlog = 1),
    biomass_floor = kb_prior_normal(mean = 0, sd = 0.2),
    tide_height_slope = kb_prior_normal(mean = 0.276, sd = 0.04),
    cv_residual = kb_prior_exponential(rate = 1),
    presence_intercept = kb_prior_normal(mean = 0, sd = 2),
    presence_cover_slope = kb_prior_normal(mean = 0, sd = 20),
    sd_site = kb_prior_exponential(rate = 1),
    sd_year = kb_prior_exponential(rate = 1)
  )
}
