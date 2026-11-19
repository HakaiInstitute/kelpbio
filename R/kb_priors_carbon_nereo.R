#' Default priors for the Nereocystis carbon model
#'
#' The default priors for the *Nereocystis luetkeana* carbon model, for the
#' `priors` argument of [kb_fit_carbon_nereo()].
#'
#' @inheritSection params Priors
#' @returns A named list of prior objects, one per parameter.
#' @family priors
#' @export
#'
#' @examples
#' kb_priors_carbon_nereo()
#' @examplesIf interactive()
#' # Change one prior; the others keep their defaults:
#' kb_fit_carbon_nereo(
#'   data_carbon_sim_nereo,
#'   priors = list(intercept = kb_prior_normal(mean = -1, sd = 0.5))
#' )
kb_priors_carbon_nereo <- function() {
  list(
    intercept = kb_prior_normal(mean = -0.8, sd = 0.3),
    precision = kb_prior_exponential(rate = 0.001)
  )
}
