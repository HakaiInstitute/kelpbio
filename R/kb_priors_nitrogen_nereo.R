#' Default priors for the Nereocystis nitrogen model
#'
#' The default priors for the *Nereocystis luetkeana* nitrogen model, for the
#' `priors` argument of [kb_fit_nitrogen_nereo()].
#'
#' @inheritSection params Priors
#' @returns A named list of prior objects, one per parameter.
#' @family priors
#' @export
#'
#' @examples
#' kb_priors_nitrogen_nereo()
#' @examplesIf interactive()
#' # Change one prior; the others keep their defaults:
#' kb_fit_nitrogen_nereo(
#'   data_nitrogen_sim_nereo,
#'   priors = list(intercept = kb_prior_normal(mean = -3.5, sd = 0.5))
#' )
kb_priors_nitrogen_nereo <- function() {
  list(
    intercept = kb_prior_normal(mean = -3.7, sd = 0.5),
    precision = kb_prior_exponential(rate = 0.001)
  )
}
