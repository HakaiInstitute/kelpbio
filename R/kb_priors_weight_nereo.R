#' Default Priors for the Nereocystis Weight Model
#'
#' The default prior list for the *Nereocystis luetkeana* allometric weight
#' model. Edit individual entries and pass the list to the `priors` argument of
#' [kb_fit_weight_nereo()] to override defaults; unmodified entries keep their
#' defaults.
#'
#' The prior family of each entry is fixed; only the hyperparameters can be
#' changed. `log_power` is on the log of the allometric exponent, `floor` is the
#' size-independent share of the expected weight at the reference diameter, and
#' `nu` is the Student-t degrees of freedom.
#'
#' @return A named list of prior objects with entries `intercept`, `log_power`,
#'   `floor`, `nu`, `sd_site`, `sd_year`, `sd_site_power`, `sd_site_year`, and
#'   `sd_residual`.
#' @family priors
#' @export
#'
#' @examples
#' priors <- kb_priors_weight_nereo()
#' priors$sd_site <- kb_prior_exponential(2)
kb_priors_weight_nereo <- function() {
  list(
    intercept = kb_prior_normal(mean = 0, sd = 2),
    # On log(bPower): the site effect is additive there, so the exponent stays
    # positive. Centred on log(2), an allometric exponent of 2.
    log_power = kb_prior_normal(mean = 0.693, sd = 0.5),
    floor = kb_prior_beta(shape1 = 1, shape2 = 5),
    nu = kb_prior_gamma(shape = 2, rate = 0.1),
    sd_site = kb_prior_exponential(rate = 1),
    sd_year = kb_prior_exponential(rate = 1),
    sd_site_power = kb_prior_exponential(rate = 1),
    sd_site_year = kb_prior_exponential(rate = 1),
    sd_residual = kb_prior_exponential(rate = 1)
  )
}
