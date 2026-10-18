#' Fit a Macrocystis density model
#'
#' Fit a plant-density model for *Macrocystis pyrifera* via Stan.
#'
#' @details
#' The number of plants on a transect is modelled with a negative binomial
#' likelihood with mean `mu` and overdispersion `dispersion`, common to all
#' transects. Plants are those with at least one frond reaching 1 m above the
#' holdfast, the same plants the size model describes.
#'
#' `mu` is the transect area times the plant density, `mu = area_m2 *
#' density`, and `density` varies by site and year, `log(density) = intercept
#' + site_effect + year_effect + site_year_effect`, so `intercept` is the log
#' plant density (plants per m²) at a typical site and year.
#'
#' @inheritSection params Sampling
#' @inheritSection params Site and year interaction
#' @inheritParams kb_fit_weight_nereo
#' @inheritParams params
#' @param data A data frame of density observations, one row per transect (see
#'   [kb_check_data_density_macro()] for the required columns).
#' @param priors A named list of prior objects (see
#'   [kb_priors_density_macro()]), or `NULL` to use the defaults. Entries not
#'   supplied keep their defaults.
#'
#' @returns An object of class
#'   `c("kb_fit_density_macro", "kb_fit_density", "kb_fit")`.
#' @family fit functions
#' @export
#'
#' @examples
#' # A pre-fit example model is included with the package:
#' tidy(fit_density_sim_macro)
#' @examplesIf interactive()
#' fit <- kb_fit_density_macro(data_density_sim_macro)
#' tidy(fit)
kb_fit_density_macro <- function(
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
    kb_check_data_density_macro,
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

  priors <- resolve_priors(priors, kb_priors_density_macro())
  stan_data <- assemble_density_macro_data(
    data,
    priors,
    prior_only = prior_only
  )

  parameters <- fit_parameters(priors, GROUP_EFFECTS)
  core <- fit_stan(
    stanmodels$density_macro,
    stan_data,
    param_vars = c(parameters$fixed, parameters$random),
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir,
    stanmodel_name = "density_macro",
    ...
  )

  new_kb_fit(
    core,
    data = data,
    priors = priors,
    model = "density",
    species = "macrocystis",
    # Counts are over the area surveyed, so the expected count is area times
    # density.
    offset = "area_m2",
    terms = parameters,
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(
      site_year_on = TRUE,
      # No predictor: density is predicted per group.
      response = "plants"
    )
  )
}
