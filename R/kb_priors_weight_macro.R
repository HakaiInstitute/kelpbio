#' Default Priors for the Macrocystis Weight Model
#'
#' The default priors for the *Macrocystis pyrifera* allometric weight model. To
#' change a prior, pass a list of the entries to change to the `priors` argument
#' of [kb_fit_weight_macro()]; the other entries keep their defaults.
#'
#' Each entry is named after the parameter it sets, as reported by [tidy()] and
#' [kb_model_describe()]. The prior family of each entry is fixed (the
#' intercept and slope are Normal, the Gamma shape and standard deviations are
#' Exponential); only the hyperparameters can be changed. `intercept` is the log
#' expected weight at the geometric mean frond count, and `fronds_slope` the
#' slope of log expected weight on log frond count.
#'
#' @return A named list of prior objects with entries `intercept`,
#'   `fronds_slope`, `shape`, `sd_site`, `sd_year`, and `sd_site_year`.
#' @family priors
#' @export
#'
#' @examples
#' kb_priors_weight_macro()
#' # Change one prior; the others keep their defaults:
#' if (interactive()) {
#'   kb_fit_weight_macro(
#'     data_weight_sim_macro,
#'     priors = list(sd_site = kb_prior_exponential(rate = 2))
#'   )
#' }
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
