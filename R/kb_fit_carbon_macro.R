#' Fit a Macrocystis carbon model
#'
#' Fit a carbon-fraction model for *Macrocystis pyrifera* via Stan.
#'
#' @details
#' The carbon fraction of each dried sample, its carbon mass divided by its
#' mass (`carbon_mass_ug` converted to mg, divided by `sample_mass_mg`), is
#' modelled with a Beta likelihood with mean `mu` and precision `precision`,
#' both common to all samples, so `mu` is the expected fraction and
#' `logit(mu) = intercept`.
#'
#' Samples are pooled over the months, sites, and tissues they come from. To
#' estimate the fraction for a particular season, fit the model to that
#' season's samples only.
#'
#' @inheritSection params Sampling
#' @inheritParams kb_fit_weight_nereo
#' @inheritParams params
#' @param data A data frame of carbon observations, one row per sample (see
#'   [kb_check_data_carbon_macro()] for the required columns).
#' @param priors A named list of prior objects (see [kb_priors_carbon_macro()]),
#'   or `NULL` to use the defaults. Entries not supplied keep their defaults.
#'
#' @returns A `kb_fit_carbon_macro` object (a `kb_fit`).
#' @family fit functions
#' @export
#'
#' @examples
#' # A pre-fit example model is included with the package:
#' tidy(fit_carbon_sim_macro)
#' @examplesIf interactive()
#' fit <- kb_fit_carbon_macro(data_carbon_sim_macro)
#' tidy(fit)
kb_fit_carbon_macro <- function(
  data,
  priors = NULL,
  ...,
  prior_only = FALSE,
  chains = 4L,
  niters = 1000L,
  nthin = 1L,
  cores = NULL,
  seed = NULL,
  progress = c("bar", "verbose", "none"),
  progress_dir = NULL
) {
  fit_beta_model(
    data,
    priors,
    model = "carbon",
    response = "carbon_fraction",
    check_data = kb_check_data_carbon_macro,
    defaults = kb_priors_carbon_macro(),
    assemble = assemble_carbon_data,
    species = "macrocystis",
    ...,
    prior_only = prior_only,
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir
  )
}
