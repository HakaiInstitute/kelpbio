#' Parameter Descriptions for Package
#'
#' Default parameter descriptions which may be overridden in individual
#' functions.
#'
#' A flag is a non-missing logical scalar.
#'
#' A string is a non-missing character scalar.
#'
#' @section Sampling:
#' `niters` is the number of saved post-warmup draws per chain; warmup defaults to
#' match `niters` and the post-warmup phase is thinned by `nthin`.
#'
#' `progress` controls fit-time console output. The default `"bar"` shows a
#' progress bar; `"verbose"` streams rstan's per-iteration output and its
#' post-sampling diagnostic warnings; `"none"` is silent. `progress` changes only
#' console output, never the fit; inspect convergence with [converged()],
#' [glance()], or [summary()] in every mode.
#'
#' Supply `progress_dir` (an existing directory) to have the fit write a progress
#' record there, which [kb_progress()] reads to report the completed fraction
#' from another R process (for example, to drive a progress indicator while the fit
#' runs in the background).
#'
#' Chains run in parallel by default (`cores = NULL` uses `getOption("mc.cores")`,
#' falling back to `chains`, capped at the available cores). Set
#' `options(mc.cores = 1)` (or pass `cores = 1`) on shared servers, in containers,
#' or inside another parallel context.
#'
#' The sampler runs with `adapt_delta = 0.95` by default, which reduces divergences
#' at the cost of slightly longer runtime. Override it, or set any other sampler
#' control, by passing a `control` list through `...`, e.g.
#' `control = list(adapt_delta = 0.99)`; only the entries supplied are changed. See
#' the `control` argument of [rstan::stan()] for the full set of entries.
#
#' @inheritParams rlang::args_dots_empty
#' @param data A data frame of weight observations (see
#'   [kb_check_data_weight_nereo()] for the required columns).
#' @param priors A named list of prior objects (see [kb_priors_weight_nereo()]), or
#'   `NULL` to use the defaults. Supplied entries override the corresponding
#'   defaults; unspecified entries keep their defaults.
#' @param prior_only A flag specifying whether to sample from the priors only
#'   (the likelihood is switched off), for prior predictive checks.
#' @param chains A whole number of MCMC chains.
#' @param niters A whole number of saved post-warmup draws per chain (warmup
#'   defaults to match).
#' @param nthin A whole number giving the thinning interval.
#' @param cores A whole number of cores for parallel chains, or `NULL` to use
#'   `getOption("mc.cores")` (falling back to `chains`), capped at the available
#'   cores.
#' @param seed A whole number passed to [rstan::sampling()] to make the fit
#'   reproducible, or `NULL` (the default). When `NULL`, a seed is drawn from R's
#'   RNG, so a preceding `set.seed()` also makes the fit reproducible; an explicit
#'   `seed` takes precedence over the RNG state.
#' @param progress A string, one of `"bar"` (the default, a console progress
#'   bar), `"verbose"` (rstan's per-iteration output and diagnostic warnings), or
#'   `"none"` (silent). Controls fit-time console output only.
#' @param progress_dir A string giving an existing directory in which to write a
#'   pollable progress artifact (read by [kb_progress()]), or `NULL` (the
#'   default) to write none.
#' @param conf_level A number between 0 and 1 giving the compatibility-interval
#'   level.
#' @param estimate A function that reduces a numeric vector of posterior draws to
#'   a scalar point estimate (e.g. `median` or `mean`).
#' @param sig_fig A whole number of significant figures for summary output.
#' @param include_random_effects A flag specifying whether to include the
#'   group-level random-effect terms in the output.
#' @param rhat A number giving the maximum acceptable Rhat.
#' @param esr A number giving the minimum acceptable effective sample rate
#'   (effective sample size divided by the number of draws).
#' @param max_perc_divergent A number giving the maximum acceptable percentage of
#'   saved draws that ended in a divergent transition. `0` requires a fit with no
#'   divergent transitions.
#' @param by A character vector of grouping factors, each drawn as a separate
#'   curve, or `NULL` for a single population-level curve. Each named factor is
#'   expanded over its observed levels and conditioned on its estimated random
#'   effects.
#' @param new_levels A string, one of `"sample"` or `"average"`, controlling how
#'   random effects that are not conditioned on are treated (factors absent from
#'   the prediction, and any new level not seen in the fit). `"sample"` draws a
#'   new random effect from `Normal(0, sd)`, widening the interval to include
#'   between-group variation; `"average"` holds the random effects at zero,
#'   giving the typical (median) group rather than the average over the
#'   random-effect distribution. Known levels are always conditioned on. `"sample"`
#'   draws fresh randomness on each call, so set a seed with `set.seed()` for a
#'   reproducible interval.
#' @param representative_site A character vector of site levels present in the
#'   fit, or `NULL` (the default). When supplied, a new or absent site takes the
#'   named reference site's site effect (the per-draw average when several are
#'   named) instead of the `new_levels` treatment. Any `site:year` interaction
#'   still follows `new_levels`.
#' @keywords internal
#' @aliases parameters arguments args
#' @usage NULL
# nocov start
params <- function(...) NULL
# nocov end
