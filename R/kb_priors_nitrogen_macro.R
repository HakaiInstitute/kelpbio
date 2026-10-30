#' Default priors for the Macrocystis nitrogen model
#'
#' The default priors for the *Macrocystis pyrifera* nitrogen model. To change a
#' prior, pass a list of the entries to change to the `priors` argument of
#' [kb_fit_nitrogen_macro()]; the other entries keep their defaults.
#'
#' @inherit kb_priors_nitrogen_nereo details return
#' @family priors
#' @export
#'
#' @examples
#' kb_priors_nitrogen_macro()
#' @examplesIf interactive()
#' # Change one prior; the others keep their defaults:
#' kb_fit_nitrogen_macro(
#'   data_nitrogen_sim_macro,
#'   priors = list(intercept = kb_prior_normal(mean = -3.5, sd = 0.5))
#' )
kb_priors_nitrogen_macro <- function() {
  list(
    intercept = kb_prior_normal(mean = -3.7, sd = 0.5),
    precision = kb_prior_exponential(rate = 0.001)
  )
}
