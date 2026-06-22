#' Fit the Weight Model
#'
#' Fit the full allometric weight model (quadratic log-diameter mean with site
#' intercept, site slope, and site:year random effects, Student-t likelihood) to
#' weight data via Stan.
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
#' `kb_fit_weight(data, control = list(adapt_delta = 0.99))`; only the entries
#' supplied are changed.
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
#'   fit <- kb_fit_weight(data_weight_sim)
#'   tidy(fit)
#' }
#' # A pre-fit example model ships with the package:
#' tidy(fit_weight)
kb_fit_weight <- function(data,
                          species = "nereocystis",
                          priors = NULL,
                          prior_only = FALSE,
                          chains = 4L,
                          niters = 1000L,
                          nthin = 1L,
                          cores = NULL,
                          quiet = FALSE,
                          ...) {
  species <- rlang::arg_match(species)
  chk::chk_flag(prior_only)
  chk::chk_whole_number(chains)
  chk::chk_gt(chains, value = 0)
  chk::chk_whole_number(niters)
  chk::chk_gt(niters, value = 0)
  chk::chk_whole_number(nthin)
  chk::chk_gt(nthin, value = 0)
  chk::chk_flag(quiet)
  if (!is.null(cores)) {
    chk::chk_whole_number(cores)
    chk::chk_gt(cores, value = 0)
  }

  kb_check_data_weight(data)
  priors <- resolve_priors(priors, kb_priors_weight(species))
  stan_data <- assemble_stan_data(data, priors, prior_only = prior_only)

  # niters = saved post-warmup draws/chain. rstan's iter counts warmup, so set
  # warmup = niters and thin the post-warmup phase to land exactly niters draws.
  warmup <- as.integer(niters)
  total_iter <- warmup + as.integer(niters) * as.integer(nthin)

  # Raise adapt_delta above Stan's 0.8 default for the hierarchical geometry;
  # power users can override any control entry via `control` in `...`. Merge so a
  # user `control` does not collide with the default or drop our other entries.
  dots <- list(...)
  control <- utils::modifyList(list(adapt_delta = 0.95), dots$control %||% list())
  dots$control <- NULL

  fit <- with_quiet_sampler(
    do.call(rstan::sampling, c(
      list(
        stanmodels$weight,
        data = stan_data,
        chains = as.integer(chains),
        iter = total_iter,
        warmup = warmup,
        thin = as.integer(nthin),
        cores = resolve_cores(cores, chains),
        refresh = if (quiet) 0L else max(1L, total_iter %/% 10L),
        show_messages = FALSE,
        # Console progress only; the HTML viewer pops a "URL cannot be accessed"
        # error in some GUIs.
        open_progress = FALSE,
        control = control
      ),
      dots
    ))
  )

  new_kb_fit_weight(
    fit,
    data = data,
    priors = priors,
    species = species,
    prior_only = prior_only,
    nthin = as.integer(nthin)
  )
}

# Muffle the post-sampling HMC diagnostic warnings (divergences, treedepth, low
# ESS/Rhat); convergence is surfaced through converged()/glance() instead.
with_quiet_sampler <- function(expr) {
  pattern <- paste(
    "divergent", "treedepth", "Effective Samples Size",
    "Examine the pairs", "R-hat", "Bayesian Fraction of Missing",
    sep = "|"
  )
  withCallingHandlers(
    expr,
    warning = function(w) {
      if (grepl(pattern, conditionMessage(w), ignore.case = TRUE)) {
        invokeRestart("muffleWarning")
      }
    }
  )
}

# NULL respects getOption("mc.cores") and falls back to `chains`, capped at the
# available cores so the default never oversubscribes, floored at 1.
resolve_cores <- function(cores, chains) {
  if (is.null(cores)) {
    cores <- getOption("mc.cores", chains)
  }
  cores <- as.integer(cores)
  avail <- parallel::detectCores()
  if (!is.na(avail)) {
    cores <- min(cores, avail)
  }
  max(1L, cores)
}

# Construct a kb_fit_weight from a stanfit: keep the extracted draws (as rvars),
# diagnostics, data, and meta; discard the stanfit.
new_kb_fit_weight <- function(stanfit, data, priors, species, prior_only, nthin) {
  param_vars <- c(
    "bWeight30", "bDiameter", "bDiameter2",
    "sSite", "sSiteDiameter", "sSiteYear", "sWeight",
    "bSite", "bSiteDiameter", "bSiteYear"
  )
  all_draws <- posterior::as_draws_rvars(stanfit)
  # Keep model parameters separate from the log_lik / yrep generated quantities
  # (stored in fit$gq for loo / pp_check) so they do not pollute pars/samples.
  draws <- posterior::subset_draws(all_draws, variable = param_vars)
  gq <- NULL
  if (nrow(data) > 0L) {
    gq <- posterior::subset_draws(all_draws, variable = c("log_lik", "yrep"))
  }

  # Convergence summary over the model parameters; suppress diagnostic warnings.
  summary <- suppressWarnings(posterior::summarise_draws(
    draws,
    rhat = posterior::rhat,
    ess_bulk = posterior::ess_bulk,
    ess_tail = posterior::ess_tail
  ))
  sampler <- rstan::get_sampler_params(stanfit, inc_warmup = FALSE)
  ndivergent <- sum(vapply(sampler, function(x) sum(x[, "divergent__"]), numeric(1)))

  meta <- list(
    species = species,
    prior_only = prior_only,
    priors = priors,
    stancode = rstan::get_stancode(stanfit),
    site_levels = levels(factor(data$site)),
    year_levels = levels(factor(data$year)),
    diameter_ref = 30,
    nu = 4, # Student-t degrees of freedom (fixed in inst/stan/weight.stan)
    nthin = nthin
  )

  structure(
    list(
      draws = draws,
      gq = gq,
      diagnostics = list(summary = summary, ndivergent = ndivergent),
      data = data,
      meta = meta
    ),
    class = c("kb_fit_weight", "kb_fit")
  )
}
