#' Default Priors for the Nereocystis Size Model
#'
#' The default prior list for the *Nereocystis luetkeana* size model. Edit
#' individual entries and pass the list to the `priors` argument of
#' [kb_fit_size_nereo()] to override defaults; unmodified entries keep their
#' defaults.
#'
#' Each entry is named after the parameter it sets, as reported by [tidy()] and
#' [kb_model_describe()]. The prior family of each entry is fixed (the intercept is Normal, the Weibull
#' shape and standard deviations are Exponential); only the hyperparameters can be
#' changed.
#'
#' @return A named list of prior objects with entries `intercept` (the log mean
#'   diameter), `shape` (the Weibull shape), `sd_site`, `sd_year`, and
#'   `sd_site_year`.
#' @family priors
#' @export
#'
#' @examples
#' priors <- kb_priors_size_nereo()
#' priors$sd_site <- kb_prior_exponential(2)
# Unlike the analysis project (Normal(1, 1) on the log shape), the shape is
# estimated directly with a weak Exponential(0.1) prior.
kb_priors_size_nereo <- function() {
  list(
    intercept = kb_prior_normal(mean = 0, sd = 2),
    shape = kb_prior_exponential(rate = 0.1),
    sd_site = kb_prior_exponential(rate = 1),
    sd_year = kb_prior_exponential(rate = 1),
    sd_site_year = kb_prior_exponential(rate = 1)
  )
}
