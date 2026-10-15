#' Default Priors for the Macrocystis Size Model
#'
#' The default priors for the *Macrocystis pyrifera* size model. To change a
#' prior, pass a list of the entries to change to the `priors` argument of
#' [kb_fit_size_macro()]; the other entries keep their defaults.
#'
#' Each entry is named after the parameter it sets, as reported by [tidy()] and
#' [kb_model_describe()]. The prior family of each entry is fixed (the intercept is Normal, the
#' overdispersion and standard deviations are Exponential); only the
#' hyperparameters can be changed.
#'
#' @return A named list of prior objects with entries `intercept` (the log mean
#'   frond count before truncation), `dispersion` (the negative binomial
#'   overdispersion), `sd_site`, `sd_year`, and `sd_site_year`.
#' @family priors
#' @export
#'
#' @examples
#' kb_priors_size_macro()
#' # Change one prior; the others keep their defaults:
#' if (interactive()) {
#'   kb_fit_size_macro(
#'     data_size_sim_macro,
#'     priors = list(dispersion = kb_prior_exponential(rate = 2))
#'   )
#' }
kb_priors_size_macro <- function() {
  list(
    intercept = kb_prior_normal(mean = 0, sd = 2),
    dispersion = kb_prior_exponential(rate = 1),
    sd_site = kb_prior_exponential(rate = 1),
    sd_year = kb_prior_exponential(rate = 1),
    sd_site_year = kb_prior_exponential(rate = 1)
  )
}
