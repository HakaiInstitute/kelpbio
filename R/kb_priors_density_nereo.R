#' Default Priors for the Nereocystis Density Model
#'
#' The default prior list for the *Nereocystis luetkeana* density model. Edit
#' individual entries and pass the list to the `priors` argument of
#' [kb_fit_density_nereo()] to override defaults; unmodified entries keep their
#' defaults.
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
#' priors <- kb_priors_density_nereo()
#' priors$logit_zero_inflation <- kb_prior_normal(mean = -1, sd = 1)
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
