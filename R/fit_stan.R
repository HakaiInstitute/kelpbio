# Seconds between progress polls in the console "bar" path.
POLL_INTERVAL <- 0.2

# Model- and species-agnostic sampling engine shared by every kb_fit_* function:
# sample, extract the draws as rvars, split off the generated quantities,
# summarise convergence, and discard the live stanfit. niters is saved post-warmup
# draws/chain; rstan's iter counts warmup, so warmup = niters and the post-warmup
# phase is thinned by nthin to land exactly niters draws.
#
# progress controls fit-time console output ("bar", "verbose", "none"); see the
# fitting spec. "bar" runs sampling in a callr background process and polls a
# progress artifact to drive a cli bar (stanmodel_name re-fetches the compiled
# model in that process, since the model's external pointer cannot cross it).
# "verbose"/"none" sample in-process. A progress artifact is written whenever
# progress_dir is supplied (any mode) or for the internal "bar" temp directory.
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

  # Model-free, serialisable argument list (shared by the in-process and
  # background paths); the compiled model is prepended separately.
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
  # Pass seed only when supplied; absent, rstan derives its own from R's RNG, so
  # set.seed() still makes the fit reproducible.
  if (!is.null(seed)) {
    sampling_args$seed <- as.integer(seed)
  }
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
  sampler <- rstan::get_sampler_params(stanfit, inc_warmup = FALSE)
  ndivergent <- sum(purrr::map_dbl(sampler, function(x) {
    sum(x[, "divergent__"])
  }))

  list(
    draws = draws,
    gq = gq,
    diagnostics = list(summary = summary, ndivergent = ndivergent),
    stancode = rstan::get_stancode(stanfit)
  )
}

# Run sampling in a callr background process and poll the progress artifact to
# drive a cli progress bar. The background process re-fetches the compiled model
# by name (its external pointer cannot cross the process boundary); rstan remains
# the source of truth for the returned stanfit. The bar is fed rows counted from
# the sample_file, so a polling glitch can only misplace the bar, never the fit.
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
  # chains/warmup/thin live in sampling_args (rstan's vocabulary); niters is the
  # package-level count the progress bar needs but rstan folds into iter.
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

# The default fits chains in parallel across the available cores with no user
# action, so the happy path stays silent (the bar carries it). Speak only when
# there are idle cores to use: more than one core exists but the run is sampling
# one chain at a time, the sole case where the user can act on the advice.
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

# Muffle rstan's post-sampling HMC diagnostic warnings (progress "bar"/"none").
# With progress = "verbose" they propagate so the user sees rstan's full
# diagnostics (divergences, treedepth, BFMI, Rhat/ESS) at fit time;
# converged()/glance()/summary() give the structured convergence summary either
# way.
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

# NULL respects getOption("mc.cores"), falling back to chains, capped at the
# available cores so the default never oversubscribes. On Windows, dev runs via
# load_all() should pass cores = 1: parallel chains spawn separate processes that
# load the installed package, not the load_all() session.
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
