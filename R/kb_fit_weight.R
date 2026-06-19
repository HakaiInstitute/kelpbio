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
#' @inheritParams params
#' @param ... Additional arguments passed to [rstan::sampling()].
#'
#' @return An object of class `c("kb_fit_weight", "kb_fit")`.
#' @family model
#' @export
#'
#' @examples
#' if (interactive()) {
#'   # Prior predictive check: fit from the priors only, then predict and plot
#'   # the implied weight-vs-diameter relationship over the data.
#'   fit <- kb_fit_weight(kb_data_weight, prior_only = TRUE)
#'   kb_predict_weight(fit, new_levels = "average") |>
#'     kb_plot_predictions(observed = kb_data_weight)
#' }
kb_fit_weight <- function(data,
                          species = "nereocystis",
                          priors = NULL,
                          prior_only = FALSE,
                          chains = 4L,
                          niters = 1000L,
                          nthin = 10L,
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

  # niters = saved post-warmup draws/chain. Translate to rstan's iter (which
  # counts warmup): warmup = niters, post-warmup = niters * nthin thinned by
  # nthin -> exactly niters saved draws.
  warmup <- as.integer(niters)
  total_iter <- warmup + as.integer(niters) * as.integer(nthin)

  fit <- with_quiet_sampler(
    rstan::sampling(
      stanmodels$weight,
      data = stan_data,
      chains = as.integer(chains),
      iter = total_iter,
      warmup = warmup,
      thin = as.integer(nthin),
      cores = cores %||% as.integer(chains),
      refresh = if (quiet) 0L else max(1L, total_iter %/% 10L),
      show_messages = FALSE,
      ...
    )
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

# Run a sampling call, muffling the post-sampling HMC diagnostic warnings
# (divergences, treedepth, low ESS/Rhat) locally at the call site. Convergence
# is surfaced through converged()/glance()/print() instead. Not a global option.
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

# Construct a kb_fit_weight from a stanfit: keep the extracted draws (as rvars),
# diagnostics, data, and meta; discard the stanfit.
new_kb_fit_weight <- function(stanfit, data, priors, species, prior_only, nthin) {
  param_vars <- c(
    "bWeight30", "bDiameter", "bDiameter2",
    "sSite", "sSiteDiameter", "sSiteYear", "sWeight",
    "bSite", "bSiteDiameter", "bSiteYear"
  )
  all_draws <- posterior::as_draws_rvars(stanfit)
  # Parameter draws power tidy/coef/diagnostics/accessors. The log_lik / yrep
  # generated quantities are stored separately (fit$gq) for loo / pp_check, so
  # they do not pollute npars/pars/samples. They are absent under a zero-row fit.
  draws <- posterior::subset_draws(all_draws, variable = param_vars)
  gq <- NULL
  if (nrow(data) > 0L) {
    gq <- posterior::subset_draws(all_draws, variable = c("log_lik", "yrep"))
  }

  # Convergence summary over the model parameters only. Stored on the fit;
  # converged()/print() surface them, so suppress the diagnostic warnings here.
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
