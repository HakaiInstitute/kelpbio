#' Default Priors for the Macrocystis Density Model
#'
#' The default prior list for the *Macrocystis pyrifera* density model. Edit
#' individual entries and pass the list to the `priors` argument of
#' [kb_fit_density_macro()] to override defaults; unmodified entries keep their
#' defaults.
#'
#' The prior family of each entry is fixed (the intercept is Normal, the
#' overdispersion and standard deviations are Exponential); only the
#' hyperparameters can be changed.
#'
#' @return A named list of prior objects with entries `intercept` (the log plant
#'   density per m²), `dispersion` (the negative binomial overdispersion),
#'   `sd_site`, `sd_year`, and `sd_site_year`.
#' @family priors
#' @export
#'
#' @examples
#' priors <- kb_priors_density_macro()
#' priors$dispersion <- kb_prior_exponential(2)
kb_priors_density_macro <- function() {
  list(
    intercept = kb_prior_normal(mean = 0, sd = 2),
    dispersion = kb_prior_exponential(rate = 1),
    sd_site = kb_prior_exponential(rate = 1),
    sd_year = kb_prior_exponential(rate = 1),
    sd_site_year = kb_prior_exponential(rate = 1)
  )
}
