#' Default priors for the Nereocystis size model
#'
#' The default priors for the *Nereocystis luetkeana* size model. To change a
#' prior, pass a list of the entries to change to the `priors` argument of
#' [kb_fit_size_nereo()]; the other entries keep their defaults.
#'
#' Each entry is named after the parameter it sets, as reported by [tidy()] and
#' [kb_model_describe()]. The prior family of each entry is fixed (the intercept is Normal, the Weibull
#' shape and standard deviations are Exponential); only the hyperparameters can be
#' changed.
#'
#' @returns A named list of prior objects with entries `intercept` (the log mean
#'   diameter), `shape` (the Weibull shape), `sd_site`, `sd_year`, and
#'   `sd_site_year`.
#' @family priors
#' @export
#'
#' @examples
#' kb_priors_size_nereo()
#' @examplesIf interactive()
#' # Change one prior; the others keep their defaults:
#' kb_fit_size_nereo(
#'   data_size_sim_nereo,
#'   priors = list(sd_site = kb_prior_exponential(rate = 2))
#' )
# Unlike the analysis project (Normal(1, 1) on the log shape), the shape is
# estimated directly with a weak Exponential(0.1) prior, as the Macrocystis
# weight shape is; the data dominate it.
kb_priors_size_nereo <- function() {
  list(
    intercept = kb_prior_normal(mean = 0, sd = 2),
    shape = kb_prior_exponential(rate = 0.1),
    sd_site = kb_prior_exponential(rate = 1),
    sd_year = kb_prior_exponential(rate = 1),
    sd_site_year = kb_prior_exponential(rate = 1)
  )
}
