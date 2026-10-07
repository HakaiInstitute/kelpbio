#' Fit a Macrocystis Size Model
#'
#' Fit a size-distribution model for *Macrocystis pyrifera* via Stan.
#'
#' @details
#' The number of fronds reaching 1 m above the holdfast is modelled with a
#' zero-truncated negative binomial likelihood, since plants without such a
#' frond are not recorded. The log mean before truncation (`intercept`) varies by
#' site, by year, and by `site:year`; the overdispersion (`dispersion`) is
#' common to all plants. Predictions report the mean of the truncated
#' distribution: the expected frond count of a plant with at least one frond at
#' 1 m.
#'
#' The site:year effect is set from the data: it is omitted when the data span a
#' single year and included otherwise. When no site spans more than one year it is
#' kept with a warning, since the site and site:year effects cannot then be
#' interpreted separately.
#'
#' @inheritSection params Sampling
#' @inheritParams params
#' @param data A data frame of size observations, one row per plant (see
#'   [kb_check_data_size_macro()] for the required columns).
#' @param priors A named list of prior objects (see [kb_priors_size_macro()]),
#'   or `NULL` to use the defaults. Supplied entries override the corresponding
#'   defaults; unspecified entries keep their defaults.
#' @param ... Additional arguments passed to [rstan::sampling()], including a
#'   `control` list (merged over the `adapt_delta = 0.95` default); see the
#'   `control` argument of [rstan::stan()] for the available entries.
#'
#' @return An object of class `c("kb_fit_size_macro", "kb_fit_size", "kb_fit")`.
#' @family model
#' @export
#'
#' @examples
#' if (interactive()) {
#'   fit <- kb_fit_size_macro(data_size_sim_macro)
#'   tidy(fit)
#' }
#' # A pre-fit example model is included with the package:
#' tidy(fit_size_sim_macro)
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

  kb_check_data_size_macro(data)
  site_year <- site_year_structure(data)
  notify_site_year(site_year, progress = progress)

  priors <- resolve_priors(priors, kb_priors_size_macro())
  stan_data <- assemble_size_macro_data(
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
    stanmodels$size_macro,
    stan_data,
    param_vars = parameters$sampled,
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
    terms = parameters[c("fixed", "random")],
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(
      site_year_on = site_year$on,
      # No predictor: size is predicted per group.
      response = "fronds"
    )
  )
}
