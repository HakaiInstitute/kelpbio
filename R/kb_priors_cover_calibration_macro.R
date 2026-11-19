#' Default priors for the Macrocystis cover calibration model
#'
#' The default priors for the *Macrocystis pyrifera* cover calibration model,
#' for the `priors` argument of [kb_fit_cover_calibration_macro()].
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
#' kb_priors_cover_calibration_macro()
#' @examplesIf interactive()
#' # Change one prior; the others keep their defaults:
#' biomass <- kb_predict_biomass_in_situ(
#'   fit_weight_sim_macro,
#'   data_size_census_sim_macro,
#'   data_survey_in_situ_sim_macro
#' )
#' kb_fit_cover_calibration_macro(
#'   biomass,
#'   priors = list(cover_slope = kb_prior_lognormal(meanlog = 2, sdlog = 0.5))
#' )
kb_priors_cover_calibration_macro <- function() {
  list(
    cover_slope = kb_prior_lognormal(meanlog = 2, sdlog = 1),
    biomass_floor = kb_prior_normal(mean = 0.4, sd = 0.3),
    tide_height_slope = kb_prior_normal(mean = 0.227, sd = 0.03),
    cv_residual = kb_prior_exponential(rate = 1),
    presence_intercept = kb_prior_normal(mean = 0, sd = 2),
    presence_cover_slope = kb_prior_normal(mean = 0, sd = 20),
    sd_site = kb_prior_exponential(rate = 1),
    sd_year = kb_prior_exponential(rate = 1)
  )
}
