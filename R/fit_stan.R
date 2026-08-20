# Seconds between progress polls in the console "bar" path.
POLL_INTERVAL <- 0.2

# Model- and species-agnostic sampling engine shared by every kb_fit_* function:
# sample, extract draws as rvars, split off generated quantities, summarise
# convergence, discard the live stanfit. warmup = niters, then the post-warmup
# phase is thinned by nthin to land exactly niters draws/chain.
#
# progress: "bar" samples in a callr background process, polling a progress
# artifact to drive a cli bar; "verbose"/"none" sample in-process.
fit_stan <- function(
  stanmodel,
  stan_data,
  param_vars,
  gq_vars = NULL,
  chains,
  niters,
  nthin,
  cores,
  progress,
  progress_dir = NULL,
  stanmodel_name = NULL,
  seed = NULL,
  ...
) {
  warmup <- as.integer(niters)
  total_iter <- warmup + as.integer(niters) * as.integer(nthin)
  chains <- as.integer(chains)

  dots <- list(...)
  control <- utils::modifyList(
    list(adapt_delta = 0.95),
    dots$control %||% list()
  )
  dots$control <- NULL

  art <- resolve_progress_dir(progress, progress_dir)
  if (art$owned) {
    on.exit(unlink(art$dir, recursive = TRUE), add = TRUE)
  }
  if (!is.null(art$dir)) {
    write_progress_manifest(art$dir, chains, warmup, niters, nthin)
  }

  # Serialisable arg list shared by both paths; the compiled model is added later.
  sampling_args <- list(
    data = stan_data,
    chains = chains,
    iter = total_iter,
    warmup = warmup,
    thin = as.integer(nthin),
    cores = resolve_cores(cores, chains),
    refresh = if (identical(progress, "verbose")) {
      max(1L, total_iter %/% 10L)
    } else {
      0L
    },
    show_messages = FALSE,
    # The HTML progress viewer errors in some GUIs.
    open_progress = FALSE,
    control = control
  )
  if (!is.null(art$dir)) {
    sampling_args$sample_file <- progress_sample_file(art$dir)
  }
  # Resolve here (parent process) so set.seed() reproducibility survives the
  # "bar" path's callr subprocess, which starts with its own RNG.
  seed <- seed %||% sample.int(.Machine$integer.max, 1L)
  sampling_args$seed <- as.integer(seed)
  sampling_args <- c(sampling_args, dots)

  stanfit <- if (identical(progress, "bar")) {
    sample_with_bar(
      stanmodel_name,
      sampling_args,
      art$dir,
      niters
    )
  } else {
    with_quiet_sampler(
      do.call(rstan::sampling, c(list(stanmodel), sampling_args)),
      muffle = !identical(progress, "verbose")
    )
  }

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
  list(
    draws = draws,
    gq = gq,
    diagnostics = c(list(summary = summary), sampler_diagnostics(stanfit)),
    stancode = rstan::get_stancode(stanfit)
  )
}

# Run-level HMC diagnostics, from rstan's own per-iteration vectors so the rates
# match rstan's warnings. Computed here because the stanfit is discarded. E-BFMI
# is per chain, reduced to its minimum: the chain the diagnostic fires on.
sampler_diagnostics <- function(stanfit) {
  divergent <- rstan::get_divergent_iterations(stanfit)
  treedepth <- rstan::get_max_treedepth_iterations(stanfit)
  ndraws <- length(divergent)
  list(
    ndivergent = sum(divergent),
    perc_divergent = perc_of(sum(divergent), ndraws),
    perc_max_treedepth = perc_of(sum(treedepth), ndraws),
    ebfmi = min(rstan::get_bfmi(stanfit))
  )
}

# NA, not 0, for an empty denominator: an unknown rate must not pass the verdict.
perc_of <- function(n, total) {
  if (total <= 0L) {
    return(NA_real_)
  }
  100 * n / total
}

# Sample in a callr background process, polling the progress artifact to drive a
# cli bar. The child re-fetches the compiled model by name (its pointer can't
# cross the process boundary). Bar counts are cosmetic; the stanfit is the fit.
sample_with_bar <- function(
  stanmodel_name,
  sampling_args,
  dir,
  niters
) {
  if (is.null(stanmodel_name)) {
    cli::cli_abort(
      "Internal: {.code progress = \"bar\"} requires {.arg stanmodel_name}."
    )
  }
  # niters isn't in sampling_args (rstan folds it into iter); the rest are.
  chains <- sampling_args$chains
  warmup <- sampling_args$warmup
  nthin <- sampling_args$thin
  bg <- callr::r_bg(
    func = function(stanmodel_name, sampling_args) {
      model <- get("stanmodels", envir = asNamespace("kelpbio"))[[
        stanmodel_name
      ]]
      do.call(rstan::sampling, c(list(model), sampling_args))
    },
    args = list(stanmodel_name = stanmodel_name, sampling_args = sampling_args),
    supervise = TRUE
  )
  on.exit(if (bg$is_alive()) bg$kill(), add = TRUE)

  manifest <- list(
    chains = chains,
    warmup = warmup,
    niters = niters,
    nthin = nthin
  )
  total_rows <- progress_rows_per_chain(warmup, niters, nthin) * chains
  announce_sampling(chains, sampling_args$cores)
  reporter <- progress_reporter("bar")
  reporter$start(total_rows)
  while (bg$is_alive()) {
    Sys.sleep(POLL_INTERVAL)
    reporter$update(count_progress_rows(dir, manifest))
  }
  reporter$update(total_rows)
  reporter$finish()
  # Surfaces the child's error (with its backtrace) if sampling failed.
  bg$get_result()
}

# Advise only when chains would run one at a time despite idle cores, the sole
# case the user can act on; otherwise stay silent (the bar carries the happy path).
announce_sampling <- function(chains, cores) {
  avail <- parallel::detectCores()
  cores_unused <- !is.na(avail) &&
    avail > 1L &&
    chains > 1L &&
    min(chains, cores) == 1L
  if (cores_unused) {
    cli::cli_alert_info(
      "Sampling {chains} chains one at a time. Set {.arg cores} (e.g. {.code cores = {chains}}) to run them in parallel and finish sooner."
    )
  }
  invisible(NULL)
}

# Muffle rstan's post-sampling HMC diagnostic warnings for "bar"/"none"; let them
# through for "verbose". converged()/glance()/summary() give the structured
# summary regardless.
with_quiet_sampler <- function(expr, muffle) {
  if (!muffle) {
    return(expr)
  }
  pattern <- paste(
    "divergent",
    "treedepth",
    "Effective Samples Size",
    "Examine the pairs",
    "R-hat",
    "Bayesian Fraction of Missing",
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

# NULL respects getOption("mc.cores"), falling back to chains, capped at available
# cores. On Windows, load_all() dev runs should pass cores = 1 (parallel chains
# load the installed package, not the load_all() session).
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
