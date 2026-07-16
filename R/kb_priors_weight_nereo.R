#' Default Priors for the Nereocystis Weight Model
#'
#' The default prior list for the *Nereocystis luetkeana* allometric weight
#' model. Edit individual entries and pass the list to the `priors` argument of
#' [kb_fit_weight_nereo()] to override defaults; unmodified entries keep their
#' defaults.
#'
#' The prior family of each entry is fixed (the population-level terms are
#' Normal, the standard deviations are Exponential); only the hyperparameters
#' can be changed.
#'
#' @return A named list of prior objects with entries `intercept`, `diameter`,
#'   `diameter2`, `sd_site`, `sd_site_diameter`, `sd_site_year`, and
#'   `sd_residual`.
#' @family priors
#' @export
#'
#' @examples
#' priors <- kb_priors_weight_nereo()
#' priors$sd_site <- kb_prior_exponential(2)
kb_priors_weight_nereo <- function() {
  list(
    intercept        = kb_prior_normal(mean = 0, sd = 2),
    diameter         = kb_prior_normal(mean = 2, sd = 1),
    diameter2        = kb_prior_normal(mean = 0, sd = 0.5),
    sd_site          = kb_prior_exponential(rate = 1),
    sd_site_diameter = kb_prior_exponential(rate = 1),
    sd_site_year     = kb_prior_exponential(rate = 1),
    sd_residual      = kb_prior_exponential(rate = 1)
  )
}
