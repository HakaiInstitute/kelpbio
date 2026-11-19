#' Default priors for the Nereocystis cover calibration model
#'
#' The default priors for the *Nereocystis luetkeana* cover calibration model,
#' for the `priors` argument of [kb_fit_cover_calibration_nereo()].
#'
#' The presence priors apply only when the data hold a survey with no plants
#' counted.
#'
#' @inheritSection params Priors
#' @returns A named list of prior objects, one per parameter.
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
