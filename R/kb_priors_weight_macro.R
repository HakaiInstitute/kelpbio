#' Default Priors for the Macrocystis Weight Model
#'
#' The default prior list for the *Macrocystis pyrifera* allometric weight model.
#' Edit individual entries and pass the list to the `priors` argument of
#' [kb_fit_weight_macro()] to override defaults; unmodified entries keep their
#' defaults.
#'
#' Each entry is named after the parameter it sets, as reported by [tidy()] and
#' [kb_model_describe()]. The prior family of each entry is fixed (the
#' population-level terms are Normal, the Gamma shape and standard deviations are
#' Exponential); only the hyperparameters can be changed. `fronds_slope` is the
#' slope of log weight on log frond count.
#'
#' @return A named list of prior objects with entries `intercept`,
#'   `fronds_slope`, `shape`, `sd_site`, `sd_year`, and `sd_site_year`.
#' @family priors
#' @export
#'
#' @examples
#' priors <- kb_priors_weight_macro()
#' priors$sd_site <- kb_prior_exponential(2)
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
