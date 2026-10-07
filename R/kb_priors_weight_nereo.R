#' Default Priors for the Nereocystis Weight Model
#'
#' The default prior list for the *Nereocystis luetkeana* allometric weight
#' model. Edit individual entries and pass the list to the `priors` argument of
#' [kb_fit_weight_nereo()] to override defaults; unmodified entries keep their
#' defaults.
#'
#' Each entry is named after the parameter it sets, as reported by [tidy()] and
#' [kb_model_describe()]. The prior family of each entry is fixed; only the
#' hyperparameters can be changed. `intercept` is on the log of the weight above
#' the floor at the reference diameter, `diameter_power` is the allometric
#' exponent, and `weight_floor` is the weight (kg) as diameter approaches zero;
#' both are truncated at zero. `density_slope` is the effect of standardised
#' stipe density on the log scale and is used only when the data include
#' density. `sd_residual` is the residual standard deviation of log weight.
#'
#' @return A named list of prior objects with entries `intercept`,
#'   `diameter_power`, `weight_floor`, `density_slope`, `sd_site`, `sd_year`,
#'   `sd_site_year`, and `sd_residual`.
#' @family priors
#' @export
#'
#' @examples
#' priors <- kb_priors_weight_nereo()
#' priors$sd_site <- kb_prior_exponential(2)
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
