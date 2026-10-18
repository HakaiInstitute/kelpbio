#' Fit a Macrocystis weight model
#'
#' Fit an allometric weight model for *Macrocystis pyrifera* via Stan.
#'
#' @details
#' Wet weight (kg) is modelled with a Gamma likelihood with mean `mu` and shape
#' `shape`, common to all plants, so `mu` is the expected weight. `mu` is a
#' power function of frond count, `mu = alpha * x^fronds_slope`, with `x` the
#' `fronds` divided by the geometric mean frond count of the data, which is a
#' straight line on log-log axes.
#'
#' The allometric coefficient `alpha` varies by site and year,
#' `log(alpha) = intercept + site_effect + year_effect + site_year_effect`, so
#' `intercept` is the log expected weight of a plant with the geometric mean
#' frond count at a typical site and year.
#'
#' @inheritSection params Sampling
#' @inheritSection params Site and year interaction
#' @inheritParams kb_fit_weight_nereo
#' @inheritParams params
#' @param data A data frame of weight observations (see
#'   [kb_check_data_weight_macro()] for the required columns).
#' @param priors A named list of prior objects (see [kb_priors_weight_macro()]),
#'   or `NULL` to use the defaults. Entries not supplied keep their defaults.
#'
#' @returns An object of class `c("kb_fit_weight_macro", "kb_fit_weight", "kb_fit")`.
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
  site_year <- site_year_structure(data)
  notify_site_year(site_year, progress = progress)

  priors <- resolve_priors(priors, kb_priors_weight_macro())
  stan_data <- assemble_weight_macro_data(
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
    # Weight is measured per plant, not per unit of survey effort.
    offset = NULL,
    terms = parameters,
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(
      # The Stan fit's own reference, so R-side predictions center identically.
      predictor_ref = stan_data$fronds_ref,
      site_year_on = site_year$on,
      predictor = "fronds",
      response = "weight_kg"
    )
  )
}
