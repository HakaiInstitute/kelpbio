#' Fit a Nereocystis weight model
#'
#' Fit an allometric weight model for *Nereocystis luetkeana* via Stan.
#'
#' @details
#' Log wet weight (kg) is modelled with a Normal likelihood with mean `log(mu)`
#' and standard deviation `sd_residual`, so `log(mu)` is the expected log
#' weight. `form` sets `mu` as a function of sub-bulb diameter, with `x` the
#' `diameter_mm` divided by the geometric mean diameter of the data:
#'
#' - `"packard_floor"` (the default):
#'   `mu = weight_floor + alpha * x^diameter_power`, the three-parameter
#'   power function of Packard (2023). `weight_floor` makes the relationship
#'   curve on log-log axes: the local allometric exponent rises with plant
#'   size and levels off toward `diameter_power` as the floor's share of
#'   weight shrinks.
#' - `"power"`: `mu = alpha * x^diameter_power`, a power law, which is a
#'   straight line on log-log axes.
#'
#' The allometric coefficient `alpha` varies by site and year,
#' `log(alpha) = intercept + site_effect + year_effect + site_year_effect`, so
#' these effects scale the size-dependent part of the weight, while
#' `weight_floor` is common to all sites and years.
#'
#' @inheritSection params Sampling
#' @inheritSection params Site and year interaction
#' @inheritParams params
#' @param data A data frame of weight observations (see
#'   [kb_check_data_weight_nereo()] for the required columns).
#' @param priors A named list of prior objects (see [kb_priors_weight_nereo()]),
#'   or `NULL` to use the defaults. Entries not supplied keep their defaults.
#' @param form A string, one of `"packard_floor"` (the default) or `"power"`,
#'   giving the mean function of weight in diameter (see Details).
#' @param ... Additional arguments passed to [rstan::sampling()], such as
#'   `control`.
#'
#' @returns An object of class `c("kb_fit_weight_nereo", "kb_fit_weight", "kb_fit")`.
#' @references Packard, G. C. (2023). What is complex allometry? *Biology Open*,
#'   12, bio060148. \doi{10.1242/bio.060148}
#' @family fit functions
#' @export
#'
#' @examples
#' # A pre-fit example model is included with the package:
#' tidy(fit_weight_sim_nereo)
#' @examplesIf interactive()
#' fit <- kb_fit_weight_nereo(data_weight_sim_nereo)
#' tidy(fit)
kb_fit_weight_nereo <- function(
  data,
  priors = NULL,
  form = c("packard_floor", "power"),
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
  form <- rlang::arg_match(form)
  progress <- rlang::arg_match(progress)
  .chk_fit_inputs(
    data,
    kb_check_data_weight_nereo,
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

  priors <- resolve_priors(priors, kb_priors_weight_nereo())
  # Shared by the Stan fit and R-side predictions (stored in meta below).
  # 30 mm for zero-row data.
  diameter_ref <- geometric_ref(data$diameter_mm, fallback = 30)
  stan_data <- assemble_weight_nereo_data(
    data,
    priors,
    diameter_ref,
    prior_only = prior_only,
    floor_on = form == "packard_floor"
  )

  parameters <- fit_parameters(
    priors,
    GROUP_EFFECTS,
    off = c(
      if (form == "power") "weight_floor"
    )
  )
  core <- fit_stan(
    stanmodels$weight_nereo,
    stan_data,
    param_vars = c(parameters$fixed, parameters$random),
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir,
    stanmodel_name = "weight_nereo",
    ...
  )

  new_kb_fit(
    core,
    data = data,
    priors = priors,
    model = "weight",
    species = "nereocystis",
    terms = parameters,
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(
      form = form,
      predictor_ref = diameter_ref,
      site_year_on = TRUE,
      # Lets the model-level prediction and plot code stay species-agnostic.
      predictor = "diameter_mm",
      response = "weight_kg"
    )
  )
}
