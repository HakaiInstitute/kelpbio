# The Stan model's log-likelihood at random parameter values, with a copy of `fit`
# whose draws are those values. The log density with prior_only = 1 is
# subtracted, leaving the likelihood up to the constants `~` drops (Jacobian
# terms cancel).
stan_log_lik <- function(fit, ndraws = 5L, seed = 1L) {
  captured <- capture_stan_data(fit)
  prior_data <- captured$stan_data
  prior_data$prior_only <- 1L
  full <- suppressMessages(rstan::sampling(
    captured$stanmodel,
    data = captured$stan_data,
    chains = 0L
  ))
  prior <- suppressMessages(rstan::sampling(
    captured$stanmodel,
    data = prior_data,
    chains = 0L
  ))

  withr::local_seed(seed)
  npars <- rstan::get_num_upars(full)
  upars <- lapply(seq_len(ndraws), function(i) stats::rnorm(npars, sd = 0.5))
  lp <- vapply(
    upars,
    function(u) rstan::log_prob(full, u) - rstan::log_prob(prior, u),
    numeric(1)
  )
  pars <- lapply(upars, function(u) rstan::constrain_pars(full, u))
  fit$draws <- draws_from_pars(fit$draws, pars)
  list(fit = fit, lp = lp)
}

capture_stan_data <- function(fit) {
  local_mocked_bindings(
    fit_stan = function(stanmodel, stan_data, ...) {
      rlang::abort(
        "Stan data captured.",
        class = "kb_test_stan_data",
        stanmodel = stanmodel,
        stan_data = stan_data
      )
    }
  )
  fit_fun <- get(class(fit)[1], envir = asNamespace("kelpbio"))
  if (inherits(fit, "kb_fit_cover_biomass")) {
    args <- list(
      cover_surveys(fit),
      cover_biomass(fit),
      priors = fit$meta$priors,
      conf_level = fit$meta$conf_level
    )
  } else {
    args <- list(fit$data, priors = fit$meta$priors)
  }
  if (inherits(fit, "kb_fit_weight_nereo")) {
    args$form <- fit$meta$form
  }
  args$progress <- "none"
  tryCatch(
    suppressWarnings(rlang::exec(fit_fun, !!!args)),
    kb_test_stan_data = function(e) {
      list(stanmodel = e$stanmodel, stan_data = e$stan_data)
    }
  )
}

# One constrain_pars() result per draw.
draws_from_pars <- function(draws, pars) {
  for (name in names(draws)) {
    shape <- dim(draws[[name]])
    values <- vapply(pars, function(p) as.vector(p[[name]]), numeric(prod(shape)))
    values <- matrix(values, ncol = length(pars))
    new <- posterior::rvar(t(values))
    dim(new) <- shape
    dimnames(new) <- dimnames(draws[[name]])
    draws[[name]] <- new
  }
  draws
}
