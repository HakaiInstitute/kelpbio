#' Fit a Nereocystis density model
#'
#' Fit a stipe-density model for *Nereocystis luetkeana* via Stan.
#'
#' @details
#' The number of stipes on a transect is modelled with a zero-inflated
#' negative binomial likelihood, which combines two processes:
#'
#' - Occupancy: a transect is unoccupied, and so counts no stipes (a
#'   structural zero), with a probability whose logit is
#'   `logit_zero_inflation`, common to all transects.
#' - Count: on an occupied transect, the count is negative binomial with mean
#'   `mu` and overdispersion `dispersion`, common to all transects, so an
#'   occupied transect can still count no stipes (a sampling zero).
#'
#' `mu` is the transect area times the stipe density on occupied transects,
#' `mu = area_m2 * density`, and `density` varies by site and year,
#' `log(density) = intercept + site_effect + year_effect + site_year_effect`,
#' so `intercept` is the log stipe density (stipes per m²) at a typical site
#' and year. Predictions report the expected density over all transects,
#' occupied or not.
#'
#' @inheritSection params Sampling
#' @inheritSection params Site and year interaction
#' @inheritParams kb_fit_weight_nereo
#' @inheritParams params
#' @param data A data frame of density observations, one row per transect (see
#'   [kb_check_data_density_nereo()] for the required columns).
#' @param priors A named list of prior objects (see
#'   [kb_priors_density_nereo()]), or `NULL` to use the defaults. Entries not
#'   supplied keep their defaults.
#'
#' @returns An object of class
#'   `c("kb_fit_density_nereo", "kb_fit_density", "kb_fit")`.
#' @family fit functions
#' @export
#'
#' @examples
#' # A pre-fit example model is included with the package:
#' tidy(fit_density_sim_nereo)
#' @examplesIf interactive()
#' fit <- kb_fit_density_nereo(data_density_sim_nereo)
#' tidy(fit)
kb_fit_density_nereo <- function(
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
    kb_check_data_density_nereo,
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

  priors <- resolve_priors(priors, kb_priors_density_nereo())
  stan_data <- assemble_density_nereo_data(
    data,
    priors,
    prior_only = prior_only
  )

  parameters <- fit_parameters(priors, GROUP_EFFECTS)
  core <- fit_stan(
    stanmodels$density_nereo,
    stan_data,
    param_vars = c(parameters$fixed, parameters$random),
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir,
    stanmodel_name = "density_nereo",
    ...
  )

  new_kb_fit(
    core,
    data = data,
    priors = priors,
    model = "density",
    species = "nereocystis",
    # Counts are over the area surveyed, so the expected count is area times
    # density.
    offset = "area_m2",
    terms = parameters,
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(
      site_year_on = TRUE,
      # No predictor: density is predicted per group.
      response = "stipes"
    )
  )
}
