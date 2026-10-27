#' Default priors for the Macrocystis wet/dry model
#'
#' The default priors for the *Macrocystis pyrifera* wet/dry model. To change a
#' prior, pass a list of the entries to change to the `priors` argument of
#' [kb_fit_wetdry_macro()]; the other entries keep their defaults.
#'
#' Each entry is named after the parameter it sets, as reported by [tidy()] and
#' [kb_model_describe()]. The prior family of each entry is fixed (the intercept is Normal, the
#' precision is Exponential); only its arguments can be changed.
#'
#' @returns A named list of prior objects with entries `intercept` (the dry:wet
#'   ratio on the logit scale) and `precision` (the Beta precision; larger
#'   values mean less spread around the mean ratio).
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
