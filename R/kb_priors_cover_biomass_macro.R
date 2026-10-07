#' Default Priors for the Macrocystis Cover Biomass Model
#'
#' The default prior list for the *Macrocystis pyrifera* cover biomass model. Edit
#' individual entries and pass the list to the `priors` argument of
#' [kb_fit_cover_biomass_macro()] to override defaults; unmodified entries keep their
#' defaults.
#'
#' Each entry is named after the parameter it sets, as reported by [tidy()] and
#' [kb_model_describe()]. The prior family of each entry is fixed (the cover
#' slope prior is lognormal, the floor, tide, and error scaling priors are
#' Normal, and the standard deviations are Exponential); only the
#' hyperparameters can be changed. The floor, tide, and error scaling priors are
#' truncated at zero.
#'
#' @return A named list of prior objects with entries `cover_slope` (the wet
#'   biomass per m² at full tide-corrected canopy cover, at a typical site and
#'   year), `biomass_floor` (the wet biomass per m² at zero cover),
#'   `tide_height_slope` (the fractional increase in canopy area per metre of
#'   tide height), `error_scaling` (the multiplier on the log-scale SDs of the in
#'   situ biomass estimates), `sd_site`, and `sd_year`.
#' @family priors
#' @export
#'
#' @examples
#' priors <- kb_priors_cover_biomass_macro()
#' priors$cover_slope <- kb_prior_lognormal(meanlog = 2, sdlog = 0.5)
kb_priors_cover_biomass_macro <- function() {
  list(
    cover_slope = kb_prior_lognormal(meanlog = 2, sdlog = 1),
    biomass_floor = kb_prior_normal(mean = 0.4, sd = 0.3),
    tide_height_slope = kb_prior_normal(mean = 0.227, sd = 0.03),
    error_scaling = kb_prior_normal(mean = 1, sd = 0.5),
    sd_site = kb_prior_exponential(rate = 1),
    sd_year = kb_prior_exponential(rate = 1)
  )
}
