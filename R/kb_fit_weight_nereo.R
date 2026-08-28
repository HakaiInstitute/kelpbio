#' Fit a Nereocystis Weight Model
#'
#' Fit an allometric weight model for *Nereocystis luetkeana* via Stan.
#'
#' @details
#' The response is log wet weight, modelled with a Student-t likelihood (4
#' degrees of freedom, for robustness to outliers). Expected log weight is a
#' quadratic (allometric) function of log sub-bulb diameter, centered at its
#' geometric mean so the intercept is the expected log weight at a typical
#' diameter. The intercept and the allometric slope vary by site, and the
#' intercept also varies by `site:year`.
#'
#' `niters` is the number of saved post-warmup draws per chain; warmup defaults
#' to match `niters` and the post-warmup phase is thinned by `nthin`.
#' The returned object stores the extracted posterior draws, diagnostics, data,
#' and metadata.
#'
#' `progress` controls fit-time console output. The default `"bar"` shows a
#' progress bar; `"verbose"` streams rstan's per-iteration output and its
#' post-sampling diagnostic warnings; `"none"` is silent. `progress` changes only
#' console output, never the fit; inspect convergence with [converged()] /
#' [glance()] / [summary()] in every mode.
#'
#' Supply `progress_dir` (an existing directory) to have the fit write a pollable
#' progress artifact there, which [kb_fit_progress()] reads to report the
#' completed fraction from another R process (for example, to drive a progress
#' indicator while the fit runs in the background).
#'
#' Chains run in parallel by default (`cores = NULL` uses `getOption("mc.cores")`,
#' falling back to `chains`, capped at the available cores). Set
#' `options(mc.cores = 1)` (or pass `cores = 1`) on shared servers, in
#' containers, or inside another parallel context.
#'
#' The sampler runs with a conservative `adapt_delta = 0.95` by default, which
#' reduces divergences at the cost of slightly longer runtime. Override it, or
#' set any other sampler control, by passing a `control` list through `...`, e.g.
#' `kb_fit_weight_nereo(data, control = list(adapt_delta = 0.99))`; only the
#' entries supplied are changed. See the `control` argument of [rstan::stan()]
#' for the full set of tunable entries (e.g. `adapt_delta`, `max_treedepth`).
#'
#' The site:year effect is set from the data: it is dropped when the data span a
#' single year (then confounded with the site effect) and included otherwise.
#' When no site spans more than one year it is kept with a warning, since `sSite`
#' and `sSiteYear` are not then separately identified.
#'
#' @inheritParams params
#' @param ... Additional arguments passed to [rstan::sampling()], including a
#'   `control` list (merged over the `adapt_delta = 0.95` default); see the
#'   `control` argument of [rstan::stan()] for the available entries.
#'
#' @return An object of class `c("kb_fit_weight_nereo", "kb_fit_weight", "kb_fit")`.
#' @family model
#' @export
#'
#' @examples
#' if (interactive()) {
#'   fit <- kb_fit_weight_nereo(data_weight_sim_nereo)
#'   tidy(fit)
#' }
#' # A pre-fit example model is included with the package:
#' tidy(fit_weight_sim_nereo)
kb_fit_weight_nereo <- function(
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

  kb_check_data_weight_nereo(data)
  # The site:year effect is determined from the data
  site_year <- site_year_structure(data)
  notify_site_year(site_year, progress = progress)

  priors <- resolve_priors(priors, kb_priors_weight_nereo())
  # Shared by the Stan fit and R-side predictions (stored in meta below).
  diameter_ref <- weight_diameter_ref(data$diameter)
  stan_data <- assemble_weight_nereo_data(
    data,
    priors,
    diameter_ref,
    prior_only = prior_only,
    site_year_on = site_year$on
  )

  core <- fit_stan(
    stanmodels$weight_nereo,
    stan_data,
    param_vars = c(
      "bWeight",
      "bPower",
      "bFloor",
      "bNu",
      "sSite",
      "sYear",
      "sSitePower",
      "sSiteYear",
      "sWeight",
      "bSite",
      "bYear",
      "bSitePower",
      "bSiteYear"
    ),
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
    # Weight is measured per plant, not per unit of survey effort.
    offset = NULL,
    terms = list(
      fixed = c(
        "bWeight",
        "bPower",
        "bFloor",
        "bNu",
        "sSite",
        "sYear",
        "sSitePower",
        if (site_year$on) "sSiteYear",
        "sWeight"
      ),
      random = c(
        "bSite",
        "bYear",
        "bSitePower",
        if (site_year$on) "bSiteYear"
      )
    ),
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(
      predictor_ref = diameter_ref,
      site_year_on = site_year$on,
      # Predictor/response column names let the model-level prediction and plot
      # code stay species-agnostic (macro uses "fronds").
      predictor = "diameter",
      response = "weight"
    )
  )
}
