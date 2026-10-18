#' Default priors for the Nereocystis weight model
#'
#' The default priors for the *Nereocystis luetkeana* allometric weight model.
#' To change a prior, pass a list of the entries to change to the `priors`
#' argument of [kb_fit_weight_nereo()]; the other entries keep their defaults.
#'
#' Each entry is named after the parameter it sets, as reported by [tidy()] and
#' [kb_model_describe()]. The prior family of each entry is fixed; only the
#' hyperparameters can be changed. `intercept` is on the log of the weight above
#' the floor at the geometric mean diameter of the data, `diameter_power` is the
#' allometric exponent, and `weight_floor` is the weight (kg) as diameter
#' approaches zero, used only by `form = "packard_floor"`. The priors on
#' `diameter_power` and `weight_floor` are truncated at zero. `density_slope` is
#' the effect of standardised stipe density on the log scale and is used only
#' when the density term is fitted (see [kb_fit_weight_nereo()]). `sd_residual`
#' is the residual standard deviation of log weight.
#'
#' @returns A named list of prior objects with entries `intercept`,
#'   `diameter_power`, `weight_floor`, `density_slope`, `sd_site`, `sd_year`,
#'   `sd_site_year`, and `sd_residual`.
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
    density_slope = kb_prior_normal(mean = 0, sd = 0.5),
    sd_site = kb_prior_exponential(rate = 1),
    sd_year = kb_prior_exponential(rate = 1),
    sd_site_year = kb_prior_exponential(rate = 1),
    sd_residual = kb_prior_exponential(rate = 1)
  )
}
