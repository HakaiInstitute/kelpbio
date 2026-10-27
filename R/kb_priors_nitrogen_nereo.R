#' Default priors for the Nereocystis nitrogen model
#'
#' The default priors for the *Nereocystis luetkeana* nitrogen model. To change a
#' prior, pass a list of the entries to change to the `priors` argument of
#' [kb_fit_nitrogen_nereo()]; the other entries keep their defaults.
#'
#' Each entry is named after the parameter it sets, as reported by [tidy()] and
#' [kb_model_describe()]. The prior family of each entry is fixed (the intercept is Normal, the
#' precision is Exponential); only its arguments can be changed.
#'
#' @returns A named list of prior objects with entries `intercept` (the nitrogen
#'   fraction of dry mass on the logit scale) and `precision` (the Beta
#'   precision; larger values mean less spread around the mean fraction).
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
