#' Fit a Nereocystis Density Model
#'
#' Fit a stipe-density model for *Nereocystis luetkeana* via Stan.
#'
#' @details
#' The number of stipes on a transect is modelled with a zero-inflated negative
#' binomial likelihood. The expected count is the transect area times the stipe
#' density, so `area_m2` enters as an offset. The log density (`intercept`, log
#' stipes per m² on occupied transects at a typical site and year) varies by
#' site, by year, and by `site:year`. A transect is unoccupied (a structural zero)
#' with probability `zi`, estimated on the logit scale (`logit_zero_inflation`) and
#' common to all transects; an occupied transect can still count no stipes. The
#' overdispersion (`dispersion`) is also common to all transects. Predictions
#' report the expected density over all transects, occupied or not.
#'
#' The site:year effect is set from the data: it is omitted when the data span a
#' single year and included otherwise. When no site spans more than one year it is
#' kept with a warning, since the site and site:year effects cannot then be
#' interpreted separately.
#'
#' @inheritSection params Sampling
#' @inheritParams params
#' @param data A data frame of density observations, one row per transect (see
#'   [kb_check_data_density_nereo()] for the required columns).
#' @param priors A named list of prior objects (see [kb_priors_density_nereo()]),
#'   or `NULL` to use the defaults. Supplied entries override the corresponding
#'   defaults; unspecified entries keep their defaults.
#' @param ... Additional arguments passed to [rstan::sampling()], including a
#'   `control` list (merged over the `adapt_delta = 0.95` default); see the
#'   `control` argument of [rstan::stan()] for the available entries.
#'
#' @return An object of class
#'   `c("kb_fit_density_nereo", "kb_fit_density", "kb_fit")`.
#' @family model
#' @export
#'
#' @examples
#' if (interactive()) {
#'   fit <- kb_fit_density_nereo(data_density_sim_nereo)
#'   tidy(fit)
#' }
#' # A pre-fit example model is included with the package:
#' tidy(fit_density_sim_nereo)
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
  .chk_sampler_args(
    prior_only = prior_only,
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir
  )

  .with_call(kb_check_data_density_nereo(data), rlang::current_env())
  .chk_fit_rows(data, prior_only)
  data <- year_as_factor(data)
  site_year <- site_year_structure(data)
  notify_site_year(site_year, progress = progress)

  priors <- resolve_priors(priors, kb_priors_density_nereo())
  stan_data <- assemble_density_nereo_data(
    data,
    priors,
    prior_only = prior_only,
    site_year_on = site_year$on
  )

  parameters <- fit_parameters(
    priors,
    GROUP_EFFECTS,
    off = site_year_off(site_year$on)
  )
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
      site_year_on = site_year$on,
      # No predictor: density is predicted per group.
      response = "stipes"
    )
  )
}
