#' Fit a Macrocystis size model
#'
#' Fit a size-distribution model for *Macrocystis pyrifera* via Stan.
#'
#' @details
#' The number of fronds reaching 1 m above the holdfast is modelled with a
#' zero-truncated negative binomial likelihood with mean before truncation
#' `mu` and overdispersion `dispersion`, common to all plants. The truncation
#' excludes plants with no such fronds, and these should be excluded from the
#' data prior to model fitting.
#'
#' `mu` varies by site and year, `log(mu) = intercept + site_effect +
#' year_effect + site_year_effect`, so `intercept` is the log mean before
#' truncation at a typical site and year. Predictions report the mean of the
#' truncated distribution, the expected frond count of a recorded plant.
#'
#' @inheritSection params Sampling
#' @inheritSection params Site and year interaction
#' @inheritParams kb_fit_weight_nereo
#' @inheritParams params
#' @param data A data frame of size observations, one row per plant (see
#'   [kb_check_data_size_macro()] for the required columns).
#' @param priors A named list of prior objects (see [kb_priors_size_macro()]),
#'   or `NULL` to use the defaults. Entries not supplied keep their defaults.
#'
#' @returns An object of class `c("kb_fit_size_macro", "kb_fit_size", "kb_fit")`.
#' @family fit functions
#' @export
#'
#' @examples
#' # A pre-fit example model is included with the package:
#' tidy(fit_size_sim_macro)
#' @examplesIf interactive()
#' fit <- kb_fit_size_macro(data_size_sim_macro)
#' tidy(fit)
kb_fit_size_macro <- function(
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
    kb_check_data_size_macro,
    prior_only = prior_only,
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir
  )
  notify_site_year(site_year_aliasing(data))

  priors <- resolve_priors(priors, kb_priors_size_macro())
  stan_data <- assemble_size_macro_data(
    data,
    priors,
    prior_only = prior_only
  )

  parameters <- fit_parameters(priors, GROUP_EFFECTS)
  core <- fit_stan(
    stanmodels$size_macro,
    stan_data,
    param_vars = c(parameters$fixed, parameters$random),
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir,
    stanmodel_name = "size_macro",
    ...
  )

  new_kb_fit(
    core,
    data = data,
    priors = priors,
    model = "size",
    species = "macrocystis",
    # Size is measured per plant, not per unit of survey effort.
    offset = NULL,
    terms = parameters,
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(
      site_year_on = TRUE,
      # No predictor: size is predicted per group.
      response = "fronds"
    )
  )
}
