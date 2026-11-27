#' Default priors for the Macrocystis wet/dry model
#'
#' The default priors for the *Macrocystis pyrifera* wet/dry model, for the
#' `priors` argument of [kb_fit_wetdry_macro()].
#'
#' @inheritSection params Priors
#' @returns A named list of prior objects, one per parameter.
#' @family priors
#' @export
#'
#' @examples
#' kb_priors_wetdry_macro()
#' @examplesIf interactive()
#' # Change one prior; the others keep their defaults:
#' kb_fit_wetdry_macro(
#'   data_wetdry_sim_macro,
#'   priors = list(intercept = kb_prior_normal(mean = -2.4, sd = 0.5))
#' )
kb_priors_wetdry_macro <- function() {
  list(
    intercept = kb_prior_normal(mean = 0, sd = 2),
    precision = kb_prior_exponential(rate = 0.01)
  )
}
