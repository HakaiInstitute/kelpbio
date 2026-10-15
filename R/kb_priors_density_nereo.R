#' Default Priors for the Nereocystis Density Model
#'
#' The default priors for the *Nereocystis luetkeana* density model. To change a
#' prior, pass a list of the entries to change to the `priors` argument of
#' [kb_fit_density_nereo()]; the other entries keep their defaults.
#'
#' Each entry is named after the parameter it sets, as reported by [tidy()] and
#' [kb_model_describe()]. The prior family of each entry is fixed (the intercept
#' and zero inflation are Normal, the overdispersion and standard deviations are
#' Exponential); only the hyperparameters can be changed.
#'
#' @return A named list of prior objects with entries `intercept` (the log stipe
#'   density per m² on occupied transects), `logit_zero_inflation` (the
#'   probability that a transect is unoccupied, on the logit scale),
#'   `dispersion` (the negative binomial overdispersion: a transect's variance is
#'   `mu + dispersion * mu^2`), `sd_site`, `sd_year`, and `sd_site_year`.
#' @family priors
#' @export
#'
#' @examples
#' kb_priors_density_nereo()
#' # Change one prior; the others keep their defaults:
#' if (interactive()) {
#'   kb_fit_density_nereo(
#'     data_density_sim_nereo,
#'     priors = list(logit_zero_inflation = kb_prior_normal(mean = -1, sd = 1))
#'   )
#' }
kb_priors_density_nereo <- function() {
  list(
    intercept = kb_prior_normal(mean = 0, sd = 2),
    logit_zero_inflation = kb_prior_normal(mean = 0, sd = 2),
    dispersion = kb_prior_exponential(rate = 1),
    sd_site = kb_prior_exponential(rate = 1),
    sd_year = kb_prior_exponential(rate = 1),
    sd_site_year = kb_prior_exponential(rate = 1)
  )
}
