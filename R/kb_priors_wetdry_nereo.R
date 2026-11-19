#' Default priors for the Nereocystis wet/dry model
#'
#' The default priors for the *Nereocystis luetkeana* wet/dry model, for the
#' `priors` argument of [kb_fit_wetdry_nereo()].
#'
#' @inheritSection params Priors
#' @returns A named list of prior objects, one per parameter.
#' @family priors
#' @export
#'
#' @examples
#' kb_priors_wetdry_nereo()
#' @examplesIf interactive()
#' # Change one prior; the others keep their defaults:
#' kb_fit_wetdry_nereo(
#'   data_wetdry_sim_nereo,
#'   priors = list(intercept = kb_prior_normal(mean = -2.4, sd = 0.5))
#' )
kb_priors_wetdry_nereo <- function() {
  list(
    intercept = kb_prior_normal(mean = 0, sd = 2),
    precision = kb_prior_exponential(rate = 0.01)
  )
}
