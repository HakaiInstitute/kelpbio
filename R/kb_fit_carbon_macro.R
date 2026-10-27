#' Fit a Macrocystis carbon model
#'
#' Fit a carbon-fraction model for *Macrocystis pyrifera* via Stan.
#'
#' @inherit kb_fit_carbon_nereo details sections
#' @inheritParams kb_fit_carbon_nereo
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
