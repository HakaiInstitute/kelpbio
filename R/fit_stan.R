# Model- and species-agnostic sampling engine shared by every kb_fit_* function:
# sample, extract the draws as rvars, split off the generated quantities,
# summarise convergence, and discard the live stanfit. niters is saved post-warmup
# draws/chain; rstan's iter counts warmup, so warmup = niters and the post-warmup
# phase is thinned by nthin to land exactly niters draws.
fit_stan <- function(stanmodel, stan_data, param_vars,
                     gq_vars = NULL,
                     chains, niters, nthin, cores, quiet, ...) {
  warmup <- as.integer(niters)
  total_iter <- warmup + as.integer(niters) * as.integer(nthin)

  dots <- list(...)
  control <- utils::modifyList(list(adapt_delta = 0.95), dots$control %||% list())
  dots$control <- NULL

  stanfit <- with_quiet_sampler(
    do.call(rstan::sampling, c(
      list(
        stanmodel,
        data = stan_data,
        chains = as.integer(chains),
        iter = total_iter,
        warmup = warmup,
        thin = as.integer(nthin),
        cores = resolve_cores(cores, chains),
        refresh = if (quiet) 0L else max(1L, total_iter %/% 10L),
        show_messages = FALSE,
        # The HTML progress viewer errors in some GUIs.
        open_progress = FALSE,
        control = control
      ),
      dots
    ))
  )

  all_draws <- posterior::as_draws_rvars(stanfit)
  draws <- posterior::subset_draws(all_draws, variable = param_vars)
  gq <- NULL
  if (!is.null(gq_vars)) {
    gq <- posterior::subset_draws(all_draws, variable = gq_vars)
  }

  summary <- suppressWarnings(posterior::summarise_draws(
    draws,
    rhat = posterior::rhat,
    ess_bulk = posterior::ess_bulk,
    ess_tail = posterior::ess_tail
  ))
  sampler <- rstan::get_sampler_params(stanfit, inc_warmup = FALSE)
  ndivergent <- sum(vapply(sampler, function(x) sum(x[, "divergent__"]), numeric(1)))

  list(
    draws = draws,
    gq = gq,
    diagnostics = list(summary = summary, ndivergent = ndivergent),
    stancode = rstan::get_stancode(stanfit)
  )
}

# Muffle the post-sampling HMC diagnostic warnings; convergence is surfaced
# through converged()/glance() instead.
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

# NULL respects getOption("mc.cores"), falling back to chains, capped at the
# available cores so the default never oversubscribes.
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
