#' Default priors for the Nereocystis cover calibration model
#'
#' The default priors for the *Nereocystis luetkeana* cover calibration model. To
#' change a prior, pass a list of the entries to change to the `priors` argument
#' of [kb_fit_cover_calibration_nereo()]; the other entries keep their defaults.
#'
#' Each entry is named after the parameter it sets, as reported by [tidy()] and
#' [kb_model_describe()]. The prior family of each entry is fixed (the cover
#' slope prior is lognormal, the floor, tide, and `cv_residual` priors are
#' Normal, and the standard deviations are Exponential); only the
#' hyperparameters can be changed. The floor and `cv_residual` priors are
#' truncated at zero, and the tide prior at 0 and 0.5.
#'
#' @returns A named list of prior objects with entries `cover_slope` (the wet
#'   biomass per m² at full tide-corrected canopy cover, at a typical site and
#'   year), `biomass_floor` (the wet biomass per m² at zero cover),
#'   `tide_height_slope` (the share of the zero-tide canopy area lost per metre
#'   of tide height), `sd_residual` (the constant part of the residual SD,
#'   kg/m²), `cv_residual` (the part of the residual SD proportional to the
#'   expected biomass), `sd_site`, and `sd_year`.
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
#'   data_in_situ_sim_nereo
#' )
#' kb_fit_cover_calibration_nereo(
#'   biomass,
#'   priors = list(cover_slope = kb_prior_lognormal(meanlog = 2, sdlog = 0.5))
#' )
kb_priors_cover_calibration_nereo <- function() {
  list(
    cover_slope = kb_prior_lognormal(meanlog = 2, sdlog = 1),
    biomass_floor = kb_prior_normal(mean = 0, sd = 0.1),
    tide_height_slope = kb_prior_normal(mean = 0.276, sd = 0.04),
    sd_residual = kb_prior_exponential(rate = 2),
    cv_residual = kb_prior_normal(mean = 0, sd = 1),
    sd_site = kb_prior_exponential(rate = 1),
    sd_year = kb_prior_exponential(rate = 1)
  )
}
