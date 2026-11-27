#' Fit a Nereocystis carbon model
#'
#' Fit a carbon-fraction model for *Nereocystis luetkeana* via Stan.
#'
#' @inheritSection params Model
#' @inheritSection params Sampling
#' @inheritParams kb_fit_weight_nereo
#' @inheritParams params
#' @param data A data frame of carbon observations, one row per sample (see
#'   [kb_check_data_carbon_nereo()] for the required columns).
#' @param priors A named list of prior objects (see [kb_priors_carbon_nereo()]),
#'   or `NULL` to use the defaults. Entries not supplied keep their defaults.
#'
#' @returns A `kb_fit_carbon_nereo` object (a `kb_fit`).
#' @family fit functions
#' @export
#'
#' @examples
#' # A pre-fit example model is included with the package:
#' tidy(fit_carbon_sim_nereo)
#' @examplesIf interactive()
#' fit <- kb_fit_carbon_nereo(data_carbon_sim_nereo)
#' tidy(fit)
kb_fit_carbon_nereo <- function(
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
    check_data = kb_check_data_carbon_nereo,
    defaults = kb_priors_carbon_nereo(),
    assemble = assemble_carbon_data,
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
