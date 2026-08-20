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
#' `niters` is the number of saved post-warmup draws per chain; warmup defaults
#' to match `niters` and the post-warmup phase is thinned by `nthin`. The returned
#' object stores the extracted posterior draws, diagnostics, data, and metadata.
#'
#' `progress` controls fit-time console output. The default `"bar"` shows a
#' progress bar; `"verbose"` streams rstan's per-iteration output and its
#' post-sampling diagnostic warnings; `"none"` is silent. `progress` changes only
#' console output, never the fit; inspect convergence with [converged()] /
#' [glance()] / [summary()] in every mode.
#'
#' Supply `progress_dir` (an existing directory) to have the fit write a pollable
#' progress artifact there, which [kb_fit_progress()] reads to report the
#' completed fraction from another R process.
#'
#' Chains run in parallel by default (`cores = NULL` uses `getOption("mc.cores")`,
#' falling back to `chains`, capped at the available cores). Set
#' `options(mc.cores = 1)` (or pass `cores = 1`) on shared servers, in
#' containers, or inside another parallel context.
#'
#' The sampler runs with a conservative `adapt_delta = 0.95` by default. Override
#' it, or set any other sampler control, by passing a `control` list through
#' `...`, e.g. `kb_fit_weight_macro(data, control = list(adapt_delta = 0.99))`;
#' only the entries supplied are changed. See the `control` argument of
#' [rstan::stan()] for the full set of tunable entries.
#'
#' The site:year effect is set from the data: it is dropped when the data span a
#' single year (then confounded with the site and year effects) and included
#' otherwise. When no site spans more than one year it is kept with a warning.
#'
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
  # The site:year effect is determined from the data
  site_year <- site_year_structure(data)
  notify_site_year(site_year, progress = progress)

  priors <- resolve_priors(priors, kb_priors_weight_macro())
  stan_data <- assemble_weight_macro_data(
    data,
    priors,
    prior_only = prior_only,
    site_year_on = site_year$on
  )

  core <- fit_stan(
    stanmodels$weight_macro,
    stan_data,
    param_vars = c(
      "bWeight",
      "bFronds",
      "shape",
      "sSite",
      "sYear",
      "sSiteYear",
      "bSite",
      "bYear",
      "bSiteYear"
    ),
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

  new_kb_fit_weight(
    core,
    data = data,
    priors = priors,
    species = "macrocystis",
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(
      # Shared by the Stan fit and R-side predictions so both center identically.
      fronds_ref = weight_fronds_ref(data$fronds),
      site_year_on = site_year$on,
      predictor = "fronds",
      response = "weight"
    )
  )
}
