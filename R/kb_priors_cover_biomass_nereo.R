#' Default Priors for the Nereocystis Cover Biomass Model
#'
#' The default prior list for the *Nereocystis luetkeana* cover biomass model. Edit
#' individual entries and pass the list to the `priors` argument of
#' [kb_fit_cover_biomass_nereo()] to override defaults; unmodified entries keep their
#' defaults.
#'
#' The prior family of each entry is fixed (the canopy, floor, tide, and scaling
#' priors are Normal, the standard deviations are Exponential); only the
#' hyperparameters can be changed. The floor, tide, and scaling priors are
#' truncated at zero.
#'
#' @return A named list of prior objects with entries `canopy` (the log of the
#'   wet biomass per m² of tide-corrected canopy at a typical site and year),
#'   `floor` (the wet biomass per m² at zero cover), `tide` (the fractional
#'   increase in canopy area per metre of tide height), `scaling` (the multiplier
#'   on the log-scale SDs of the in situ biomass estimates), `sd_site`, and
#'   `sd_year`.
#' @family priors
#' @export
#'
#' @examples
#' priors <- kb_priors_cover_biomass_nereo()
#' priors$canopy <- kb_prior_normal(mean = 2, sd = 0.5)
kb_priors_cover_biomass_nereo <- function() {
  list(
    canopy = kb_prior_normal(mean = 2, sd = 1),
    floor = kb_prior_normal(mean = 0, sd = 0.1),
    tide = kb_prior_normal(mean = 0.276, sd = 0.04),
    scaling = kb_prior_normal(mean = 1, sd = 0.5),
    sd_site = kb_prior_exponential(rate = 1),
    sd_year = kb_prior_exponential(rate = 1)
  )
}
