#' Fit a Macrocystis weight model
#'
#' Fit an allometric weight model for *Macrocystis pyrifera* via Stan.
#'
#' @inheritSection params Model
#' @inheritSection params Sampling
#' @inheritSection params Site and year interaction
#' @inheritParams kb_fit_weight_nereo
#' @inheritParams params
#' @param data A data frame of weight observations (see
#'   [kb_check_data_weight_macro()] for the required columns).
#' @param priors A named list of prior objects (see [kb_priors_weight_macro()]),
#'   or `NULL` to use the defaults. Entries not supplied keep their defaults.
#'
#' @returns A `kb_fit_weight_macro` object (a `kb_fit`).
#' @family fit functions
#' @export
#'
#' @examples
#' # A pre-fit example model ships with the package:
#' tidy(fit_weight_sim_macro)
#' @examplesIf interactive()
#' fit <- kb_fit_weight_macro(data_weight_sim_macro)
#' tidy(fit)
kb_fit_weight_macro <- function(
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
  progress <- rlang::arg_match(progress)
  .chk_fit_inputs(
    data,
    kb_check_data_weight_macro,
    prior_only = prior_only,
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir
  )
  data <- with_year(data)
  notify_site_year(site_year_aliasing(data))

  priors <- resolve_priors(priors, kb_priors_weight_macro())
  stan_data <- assemble_weight_macro_data(
    data,
    priors,
    prior_only = prior_only
  )

  parameters <- fit_parameters(priors, GROUP_EFFECTS)
  core <- fit_stan(
    stanmodels$weight_macro,
    stan_data,
    param_vars = c(parameters$fixed, parameters$random),
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir,
    stanmodel_name = "weight_macro",
    ...
  )

  new_kb_fit(
    core,
    data = data,
    priors = priors,
    model = "weight",
    species = "macrocystis",
    terms = parameters,
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(
      # The Stan fit's own reference, so R-side predictions center identically.
      predictor_ref = stan_data$fronds_ref,
      site_year_on = TRUE,
      predictor = "fronds",
      response = "weight_kg"
    )
  )
}
