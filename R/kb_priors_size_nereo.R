#' Default priors for the Nereocystis size model
#'
#' The default priors for the *Nereocystis luetkeana* size model, for the
#' `priors` argument of [kb_fit_size_nereo()].
#'
#' @inheritSection params Priors
#' @returns A named list of prior objects, one per parameter.
#' @family priors
#' @export
#'
#' @examples
#' kb_priors_size_nereo()
#' @examplesIf interactive()
#' # Change one prior; the others keep their defaults:
#' kb_fit_size_nereo(
#'   data_size_sample_sim_nereo,
#'   priors = list(sd_site = kb_prior_exponential(rate = 2))
#' )
kb_priors_size_nereo <- function() {
  list(
    intercept = kb_prior_normal(mean = 0, sd = 2),
    shape = kb_prior_exponential(rate = 0.1),
    sd_site = kb_prior_exponential(rate = 1),
    sd_year = kb_prior_exponential(rate = 1),
    sd_site_year = kb_prior_exponential(rate = 1)
  )
}
