#' Default priors for the Nereocystis weight model
#'
#' The default priors for the *Nereocystis luetkeana* weight model, for the
#' `priors` argument of [kb_fit_weight_nereo()]. `weight_floor` applies only to
#' `form = "packard_floor"`.
#'
#' @inheritSection params Priors
#' @returns A named list of prior objects, one per parameter.
#' @family priors
#' @export
#'
#' @examples
#' kb_priors_weight_nereo()
#' @examplesIf interactive()
#' # Change one prior; the others keep their defaults:
#' kb_fit_weight_nereo(
#'   data_weight_sim_nereo,
#'   priors = list(sd_site = kb_prior_exponential(rate = 2))
#' )
kb_priors_weight_nereo <- function() {
  list(
    intercept = kb_prior_normal(mean = 0, sd = 2),
    # diameter_power and weight_floor are truncated at 0 by their Stan
    # declarations.
    diameter_power = kb_prior_normal(mean = 2, sd = 1),
    weight_floor = kb_prior_normal(mean = 0, sd = 0.5),
    sd_site = kb_prior_exponential(rate = 1),
    sd_year = kb_prior_exponential(rate = 1),
    sd_site_year = kb_prior_exponential(rate = 1),
    sd_residual = kb_prior_exponential(rate = 1)
  )
}
