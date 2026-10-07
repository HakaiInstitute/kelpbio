#' Default Priors for the Macrocystis Wet/Dry Model
#'
#' The default prior list for the *Macrocystis pyrifera* wet/dry model. Edit
#' individual entries and pass the list to the `priors` argument of
#' [kb_fit_wetdry_macro()] to override defaults; unmodified entries keep their
#' defaults.
#'
#' Each entry is named after the parameter it sets, as reported by [tidy()] and
#' [kb_model_describe()]. The prior family of each entry is fixed (the intercept is Normal, the
#' precision is Exponential); only the hyperparameters can be changed.
#'
#' @return A named list of prior objects with entries `intercept` (the dry:wet
#'   mass ratio on the logit scale) and `precision` (the Beta precision; larger
#'   values mean less spread around the mean ratio).
#' @family priors
#' @export
#'
#' @examples
#' priors <- kb_priors_wetdry_macro()
#' priors$intercept <- kb_prior_normal(mean = -2.4, sd = 0.5)
kb_priors_wetdry_macro <- function() {
  list(
    intercept = kb_prior_normal(mean = 0, sd = 2),
    precision = kb_prior_exponential(rate = 0.01)
  )
}
