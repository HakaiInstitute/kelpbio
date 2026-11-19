#' Default priors for the Macrocystis weight model
#'
#' The default priors for the *Macrocystis pyrifera* weight model, for the
#' `priors` argument of [kb_fit_weight_macro()].
#'
#' @inheritSection params Priors
#' @returns A named list of prior objects, one per parameter.
#' @family priors
#' @export
#'
#' @examples
#' kb_priors_weight_macro()
#' @examplesIf interactive()
#' # Change one prior; the others keep their defaults:
#' kb_fit_weight_macro(
#'   data_weight_sim_macro,
#'   priors = list(sd_site = kb_prior_exponential(rate = 2))
#' )
kb_priors_weight_macro <- function() {
  list(
    intercept = kb_prior_normal(mean = 0, sd = 2),
    fronds_slope = kb_prior_normal(mean = 1, sd = 0.5),
    shape = kb_prior_exponential(rate = 0.1),
    sd_site = kb_prior_exponential(rate = 1),
    sd_year = kb_prior_exponential(rate = 1),
    sd_site_year = kb_prior_exponential(rate = 1)
  )
}
