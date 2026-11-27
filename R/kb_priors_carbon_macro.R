#' Default priors for the Macrocystis carbon model
#'
#' The default priors for the *Macrocystis pyrifera* carbon model, for the
#' `priors` argument of [kb_fit_carbon_macro()].
#'
#' @inheritSection params Priors
#' @returns A named list of prior objects, one per parameter.
#' @family priors
#' @export
#'
#' @examples
#' kb_priors_carbon_macro()
#' @examplesIf interactive()
#' # Change one prior; the others keep their defaults:
#' kb_fit_carbon_macro(
#'   data_carbon_sim_macro,
#'   priors = list(intercept = kb_prior_normal(mean = -1, sd = 0.5))
#' )
kb_priors_carbon_macro <- function() {
  list(
    intercept = kb_prior_normal(mean = -0.8, sd = 0.3),
    precision = kb_prior_exponential(rate = 0.001)
  )
}
