#' Fit a Macrocystis Density Model
#'
#' Fit a plant-density model for *Macrocystis pyrifera* via Stan.
#'
#' @details
#' The number of plants on a transect is modelled with a negative binomial
#' likelihood. The expected count is the transect area times the plant density, so
#' `area_m2` enters as an offset. The log density (`intercept`, log plants per m² at
#' a typical site and year) varies by site, by year, and by `site:year`; the
#' overdispersion (`dispersion`) is common to all transects.
#'
#' The site:year effect is set from the data: it is omitted when the data span a
#' single year and included otherwise. When no site spans more than one year it is
#' kept with a warning, since the site and site:year effects cannot then be
#' interpreted separately.
#'
#' @inheritSection params Sampling
#' @inheritParams params
#' @param data A data frame of density observations, one row per transect (see
#'   [kb_check_data_density_macro()] for the required columns).
#' @param priors A named list of prior objects (see [kb_priors_density_macro()]),
#'   or `NULL` to use the defaults. Supplied entries override the corresponding
#'   defaults; unspecified entries keep their defaults.
#' @param ... Additional arguments passed to [rstan::sampling()], including a
#'   `control` list (merged over the `adapt_delta = 0.95` default); see the
#'   `control` argument of [rstan::stan()] for the available entries.
#'
#' @return An object of class
#'   `c("kb_fit_density_macro", "kb_fit_density", "kb_fit")`.
#' @family model
#' @export
#'
#' @examples
#' if (interactive()) {
#'   fit <- kb_fit_density_macro(data_density_sim_macro)
#'   tidy(fit)
#' }
#' # A pre-fit example model is included with the package:
#' tidy(fit_density_sim_macro)
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

  kb_check_data_density_macro(data)
  # The site:year effect is determined from the data
  site_year <- site_year_structure(data)
  notify_site_year(site_year, progress = progress)

  priors <- resolve_priors(priors, kb_priors_density_macro())
  stan_data <- assemble_density_macro_data(
    data,
    priors,
    prior_only = prior_only,
    site_year_on = site_year$on
  )

  core <- fit_stan(
    stanmodels$density_macro,
    stan_data,
    param_vars = c(
      "intercept",
      "dispersion",
      "sd_site",
      "sd_year",
      "sd_site_year",
      "site_effect",
      "year_effect",
      "site_year_effect"
    ),
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
    terms = list(
      fixed = c(
        "intercept",
        "dispersion",
        "sd_site",
        "sd_year",
        if (site_year$on) "sd_site_year"
      ),
      random = c(
        "site_effect",
        "year_effect",
        if (site_year$on) "site_year_effect"
      )
    ),
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(
      site_year_on = site_year$on,
      # No predictor: density is predicted per group, so the grids carry no
      # predictor sequence.
      response = "plants"
    )
  )
}
