#' Fit a Nereocystis wet/dry model
#'
#' Fit a dry:wet mass ratio model for *Nereocystis luetkeana* via Stan.
#'
#' @details
#' The dry:wet ratio of each sample, `dry_mass_g / wet_mass_g`, is modelled
#' with a Beta likelihood with mean `mu` and precision `precision`, both
#' common to all samples, so `mu` is the expected ratio and `logit(mu) =
#' intercept`.
#'
#' Samples are pooled over the months, sites, and tissues they come from. To
#' estimate the ratio for a particular season, fit the model to that season's
#' samples only.
#'
#' @inheritSection params Sampling
#' @inheritParams kb_fit_weight_nereo
#' @inheritParams params
#' @param data A data frame of wet/dry observations, one row per sample (see
#'   [kb_check_data_wetdry_nereo()] for the required columns).
#' @param priors A named list of prior objects (see [kb_priors_wetdry_nereo()]),
#'   or `NULL` to use the defaults. Entries not supplied keep their defaults.
#'
#' @returns An object of class
#'   `c("kb_fit_wetdry_nereo", "kb_fit_wetdry", "kb_fit")`.
#' @family fit functions
#' @export
#'
#' @examples
#' # A pre-fit example model is included with the package:
#' tidy(fit_wetdry_sim_nereo)
#' @examplesIf interactive()
#' fit <- kb_fit_wetdry_nereo(data_wetdry_sim_nereo)
#' tidy(fit)
kb_fit_wetdry_nereo <- function(
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
    model = "wetdry",
    response = "dry_wet_ratio",
    check_data = kb_check_data_wetdry_nereo,
    defaults = kb_priors_wetdry_nereo(),
    assemble = assemble_wetdry_data,
    species = "nereocystis",
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
