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
#'  The returned object stores the extracted posterior draws (including the
#' `log_lik` and `yrep` generated quantities), diagnostics, data, and metadata.
#'
#' With the default `quiet = FALSE` the sampler's progress and warnings are
#' printed to the console; `quiet = TRUE` suppresses all sampler output. Inspect
#' convergence with [converged()] / [glance()] / [summary()].
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
#' @return An object of class `c("kb_fit_weight", "kb_fit")`.
#' @family model
#' @export
#'
#' @examples
#' if (interactive()) {
#'   fit <- kb_fit_weight_nereo(data_weight_sim_nereo)
#'   tidy(fit)
#' }
#' # A pre-fit example model ships with the package:
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
  quiet = FALSE
) {
  .chk_sampler_args(
    prior_only = prior_only,
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    quiet = quiet
  )

  kb_check_data_weight_nereo(data)
  # The site:year effect is determined from the data
  site_year <- site_year_structure(data)
  notify_site_year(site_year, quiet = quiet)

  priors <- resolve_priors(priors, kb_priors_weight_nereo())
  stan_data <- assemble_weight_nereo_data(
    data,
    priors,
    prior_only = prior_only,
    site_year_on = site_year$on
  )

  core <- fit_stan(
    stanmodels$weight_nereo,
    stan_data,
    param_vars = c(
      "bWeight",
      "bDiameter",
      "bDiameter2",
      "sSite",
      "sSiteDiameter",
      "sSiteYear",
      "sWeight",
      "bSite",
      "bSiteDiameter",
      "bSiteYear"
    ),
    gq_vars = if (nrow(data) > 0L) c("log_lik", "yrep") else NULL,
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    quiet = quiet,
    ...
  )

  new_kb_fit_weight(
    core,
    data = data,
    priors = priors,
    species = "nereocystis",
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(
      # Shared by the Stan fit and R-side predictions so both center identically.
      diameter_ref = weight_diameter_ref(data$diameter),
      site_year_on = site_year$on,
      nu = 4
    )
  )
}

# The S3 class is model-level (kb_fit_weight); species lives in meta$species and
# species-specific metadata enters via meta_extra.
new_kb_fit_weight <- function(
  core,
  data,
  priors,
  species,
  prior_only,
  nthin,
  meta_extra = list()
) {
  meta <- c(
    list(
      species = species,
      prior_only = prior_only,
      priors = priors,
      stancode = core$stancode,
      site_levels = levels(factor(data$site)),
      year_levels = levels(factor(data$year)),
      nthin = nthin
    ),
    meta_extra
  )

  structure(
    list(
      draws = core$draws,
      gq = core$gq,
      diagnostics = core$diagnostics,
      data = data,
      meta = meta
    ),
    class = c("kb_fit_weight", "kb_fit")
  )
}
