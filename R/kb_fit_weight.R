#' Fit the Weight Model
#'
#' Fit the full allometric weight model (quadratic log-diameter mean with site
#' intercept, site slope, and site:year random effects, Student-t likelihood) to
#' weight data via Stan.
#'
#' `iter` is the number of saved post-warmup draws per chain; warmup defaults to
#' match `iter` and the post-warmup phase is thinned by `nthin`. The live
#' `stanfit` is discarded after fitting: the returned object stores the extracted
#' posterior draws, diagnostics, data, and metadata (see `docs/predictions.md`).
#'
#' @inheritParams params
#' @param ... Additional arguments passed to [rstan::sampling()].
#'
#' @return An object of class `c("kb_fit_weight", "kb_fit")`.
#' @export
kb_fit_weight <- function(data,
                          species = "nereocystis",
                          priors = NULL,
                          prior_only = FALSE,
                          chains = 4L,
                          iter = 1000L,
                          nthin = 10L,
                          cores = NULL,
                          quiet = TRUE,
                          ...) {
  species <- rlang::arg_match(species)
  chk::chk_flag(prior_only)
  chk::chk_whole_number(chains)
  chk::chk_gt(chains, value = 0)
  chk::chk_whole_number(iter)
  chk::chk_gt(iter, value = 0)
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

  warmup <- as.integer(iter)
  total_iter <- warmup + as.integer(iter) * as.integer(nthin)

  fit <- rstan::sampling(
    stanmodels$weight,
    data = stan_data,
    chains = as.integer(chains),
    iter = total_iter,
    warmup = warmup,
    thin = as.integer(nthin),
    cores = cores %||% as.integer(chains),
    refresh = if (quiet) 0L else max(1L, total_iter %/% 10L),
    show_messages = !quiet,
    ...
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

# Construct a kb_fit_weight from a stanfit: keep the extracted draws (as rvars),
# diagnostics, data, and meta; discard the stanfit.
new_kb_fit_weight <- function(stanfit, data, priors, species, prior_only, nthin) {
  keep <- c(
    "bWeight30", "bDiameter", "bDiameter2",
    "sSite", "sSiteDiameter", "sSiteYear", "sWeight",
    "bSite", "bSiteDiameter", "bSiteYear"
  )
  draws <- posterior::subset_draws(
    posterior::as_draws_rvars(stanfit),
    variable = keep
  )

  # Convergence values are stored on the fit; converged()/print() surface them,
  # so suppress the small-sample diagnostic warnings here.
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
      diagnostics = list(summary = summary, ndivergent = ndivergent),
      data = data,
      meta = meta
    ),
    class = c("kb_fit_weight", "kb_fit")
  )
}
