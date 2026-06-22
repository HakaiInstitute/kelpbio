#' Fit the Nereocystis Weight Model
#'
#' Fit the full allometric weight model for *Nereocystis luetkeana* (quadratic
#' log-diameter mean with site intercept, site slope, and site:year random
#' effects, Student-t likelihood) to weight data via Stan.
#'
#' `niters` is the number of saved post-warmup draws per chain; warmup defaults
#' to match `niters` and the post-warmup phase is thinned by `nthin`. The live
#' `stanfit` is discarded after fitting: the returned object stores the extracted
#' posterior draws (including the `log_lik` and `yrep` generated quantities),
#' diagnostics, data, and metadata.
#'
#' With the default `quiet = FALSE` the sampler shows its progress but other Stan
#' output and the post-sampling HMC diagnostic warnings (divergences, treedepth,
#' low ESS/Rhat) are suppressed; inspect convergence with [converged()] /
#' [glance()].
#'
#' Chains run in parallel by default (`cores = NULL` uses `getOption("mc.cores")`,
#' falling back to `chains`, capped at the available cores). Set
#' `options(mc.cores = 1)` (or pass `cores = 1`) on shared servers, in
#' containers, or inside another parallel context. On Windows, parallel chains
#' run in separate processes that load the installed package, so use
#' `cores = 1` when running from `devtools::load_all()`.
#'
#' The sampler runs with `adapt_delta = 0.95` (a smaller leapfrog step than
#' Stan's 0.8 default, suited to the hierarchical geometry and reducing
#' divergences). Override it, or set any other sampler control, by passing a
#' `control` list through `...`, e.g.
#' `kb_fit_weight_nereo(data, control = list(adapt_delta = 0.99))`; only the
#' entries supplied are changed.
#'
#' @inheritParams params
#' @param ... Additional arguments passed to [rstan::sampling()], including a
#'   `control` list (merged over the `adapt_delta = 0.95` default).
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
#' tidy(fit_weight_hakai_nereo)
kb_fit_weight_nereo <- function(data,
                                priors = NULL,
                                prior_only = FALSE,
                                chains = 4L,
                                niters = 1000L,
                                nthin = 1L,
                                cores = NULL,
                                quiet = FALSE,
                                ...) {
  chk_sampler_args(
    prior_only = prior_only, chains = chains, niters = niters,
    nthin = nthin, cores = cores, quiet = quiet
  )

  kb_check_data_weight_nereo(data)
  priors <- resolve_priors(priors, kb_priors_weight_nereo())
  stan_data <- assemble_weight_nereo_data(data, priors, prior_only = prior_only)

  core <- fit_stan(
    stanmodels$weight_nereo,
    stan_data,
    param_vars = c(
      "bWeight", "bDiameter", "bDiameter2",
      "sSite", "sSiteDiameter", "sSiteYear", "sWeight",
      "bSite", "bSiteDiameter", "bSiteYear"
    ),
    gq_vars = if (nrow(data) > 0L) c("log_lik", "yrep") else NULL,
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
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
      nu = 4
    )
  )
}

# The S3 class is model-level (kb_fit_weight); species lives in meta$species and
# species-specific metadata enters via meta_extra.
new_kb_fit_weight <- function(core, data, priors, species, prior_only, nthin,
                              meta_extra = list()) {
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
