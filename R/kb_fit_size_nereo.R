#' Fit a Nereocystis size model
#'
#' Fit a size-distribution model for *Nereocystis luetkeana* via Stan.
#'
#' @details
#' Maximum sub-bulb diameter (mm) is modelled with a Weibull likelihood with
#' mean `mu` and shape `shape`, common to all plants, so `mu` is the expected
#' diameter.
#'
#' `mu` varies by site and year, `log(mu) = intercept + site_effect +
#' year_effect + site_year_effect`, so `intercept` is the log expected
#' diameter at a typical site and year.
#'
#' @inheritSection params Sampling
#' @inheritSection params Site and year interaction
#' @inheritParams kb_fit_weight_nereo
#' @inheritParams params
#' @param data A data frame of a size sample, one row per measured plant (see
#'   [kb_check_data_size_sample_nereo()] for the required columns).
#' @param priors A named list of prior objects (see [kb_priors_size_nereo()]),
#'   or `NULL` to use the defaults. Entries not supplied keep their defaults.
#'
#' @returns An object of class `c("kb_fit_size_nereo", "kb_fit_size", "kb_fit")`.
#' @family fit functions
#' @export
#'
#' @examples
#' # A pre-fit example model is included with the package:
#' tidy(fit_size_sim_nereo)
#' @examplesIf interactive()
#' fit <- kb_fit_size_nereo(data_size_sample_sim_nereo)
#' tidy(fit)
kb_fit_size_nereo <- function(
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
    kb_check_data_size_sample_nereo,
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

  priors <- resolve_priors(priors, kb_priors_size_nereo())
  stan_data <- assemble_size_nereo_data(
    data,
    priors,
    prior_only = prior_only
  )

  parameters <- fit_parameters(priors, GROUP_EFFECTS)
  core <- fit_stan(
    stanmodels$size_nereo,
    stan_data,
    param_vars = c(parameters$fixed, parameters$random),
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir,
    stanmodel_name = "size_nereo",
    ...
  )

  new_kb_fit(
    core,
    data = data,
    priors = priors,
    model = "size",
    species = "nereocystis",
    terms = parameters,
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(
      site_year_on = TRUE,
      # No predictor: size is predicted per group.
      response = "diameter_mm"
    )
  )
}
