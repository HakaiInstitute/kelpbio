#' Default Priors for the Nereocystis Weight Model
#'
#' The default prior list for the *Nereocystis luetkeana* allometric weight
#' model. Edit individual entries and pass the list to the `priors` argument of
#' [kb_fit_weight_nereo()] to override defaults; unmodified entries keep their
#' defaults.
#'
#' The prior family of each entry is fixed; only the hyperparameters can be
#' changed. `power` is the allometric exponent, `floor` is the
#' size-independent share of the expected weight at the reference diameter, and
#' `nu` is the Student-t degrees of freedom.
#'
#' @return A named list of prior objects with entries `intercept`, `power`,
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
    # Truncated at 0 by the Stan declaration, so this is the paper's allometry
    # prior without the mass it put on a negative (non-monotone) exponent.
    power = kb_prior_normal(mean = 2, sd = 1),
    floor = kb_prior_beta(shape1 = 1, shape2 = 5),
    nu = kb_prior_gamma(shape = 2, rate = 0.1),
    sd_site = kb_prior_exponential(rate = 1),
    sd_year = kb_prior_exponential(rate = 1),
    sd_site_power = kb_prior_exponential(rate = 1),
    sd_site_year = kb_prior_exponential(rate = 1),
    sd_residual = kb_prior_exponential(rate = 1)
  )
}
