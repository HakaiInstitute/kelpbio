#' Fit a Macrocystis Weight Model
#'
#' Fit an allometric weight model for *Macrocystis pyrifera* via Stan.
#'
#' @details
#' The response is wet weight, modelled on the natural scale with a Gamma
#' likelihood. Expected weight is a log-linear (allometric) function of log frond
#' count, centered at its geometric mean so the intercept is the expected weight
#' at a typical frond count. The Gamma shape (`shape`) is constant across plants.
#' The intercept varies by site, by year, and by `site:year`.
#'
#' The site:year effect is set from the data: it is omitted when the data span a
#' single year and included otherwise. When no site spans more than one year it is
#' kept with a warning, since the site and site:year effects cannot then be
#' interpreted separately.
#'
#' @inheritSection params Sampling
#' @inheritParams params
#' @param data A data frame of weight observations (see
#'   [kb_check_data_weight_macro()] for the required columns).
#' @param priors A named list of prior objects (see [kb_priors_weight_macro()]),
#'   or `NULL` to use the defaults. Supplied entries override the corresponding
#'   defaults; unspecified entries keep their defaults.
#' @param ... Additional arguments passed to [rstan::sampling()], including a
#'   `control` list (merged over the `adapt_delta = 0.95` default); see the
#'   `control` argument of [rstan::stan()] for the available entries.
#'
#' @return An object of class `c("kb_fit_weight_macro", "kb_fit_weight", "kb_fit")`.
#' @family model
#' @export
#'
#' @examples
#' if (interactive()) {
#'   fit <- kb_fit_weight_macro(data_weight_sim_macro)
#'   tidy(fit)
#' }
#' # A pre-fit example model ships with the package:
#' tidy(fit_weight_sim_macro)
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

  kb_check_data_weight_macro(data)
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
