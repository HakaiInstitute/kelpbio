#' Fit a Macrocystis Carbon Model
#'
#' Fit a carbon-fraction model for *Macrocystis pyrifera* via Stan.
#'
#' @details
#' The carbon fraction of each dried sample, `carbon_mass_ug / 1000 /
#' sample_mass_mg`, is modelled with a Beta likelihood parameterised by its mean
#' and precision. The logit mean fraction (`bCarbon`)
#' and the precision (`bPrecision`) are common to all samples, so the model
#' estimates one carbon fraction of dry mass for the population of samples
#' supplied.
#'
#' Samples are pooled over the months, sites, and tissues they come from. To
#' estimate the fraction for a particular season, fit the model to that season's
#' samples only.
#'
#' @inheritSection params Sampling
#' @inheritParams params
#' @param data A data frame of carbon observations, one row per sample (see
#'   [kb_check_data_carbon_macro()] for the required columns).
#' @param priors A named list of prior objects (see [kb_priors_carbon_macro()]),
#'   or `NULL` to use the defaults. Supplied entries override the corresponding
#'   defaults; unspecified entries keep their defaults.
#' @param ... Additional arguments passed to [rstan::sampling()], including a
#'   `control` list (merged over the `adapt_delta = 0.95` default); see the
#'   `control` argument of [rstan::stan()] for the available entries.
#'
#' @return An object of class
#'   `c("kb_fit_carbon_macro", "kb_fit_carbon", "kb_fit")`.
#' @family model
#' @export
#'
#' @examples
#' if (interactive()) {
#'   fit <- kb_fit_carbon_macro(data_carbon_sim_macro)
#'   tidy(fit)
#' }
#' # A pre-fit example model is included with the package:
#' tidy(fit_carbon_sim_macro)
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
    intercept = "bCarbon",
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
