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
#' Chains run in parallel by default. Set `options(mc.cores = 1)` (or pass
#' `cores = 1`) on shared servers, in containers, or inside another parallel
#' context.
#'
#' The sampler runs with `adapt_delta = 0.95` by default, which reduces
#' divergences at the cost of slightly longer runtime. Override it, or set any
#' other sampler control, by passing a `control` list through `...`, e.g.
#' `control = list(adapt_delta = 0.99)`; only the entries supplied are changed.
#' See the `control` argument of [rstan::stan()] for the full set of entries.
#'
#' Check convergence with [kb_converged()], [glance()], or [summary()].
#'
#' @section Site and year interaction:
#' The site:year effect is included when the data span more than one year. If
#' no site is surveyed in more than one year, or no year has more than one
#' site, it is included with a warning, because it cannot then be distinguished
#' from the site or year effect.
#'
#' @inheritParams rlang::args_dots_empty
#' @param fit A `kb_fit` object.
#' @param object A `kb_fit` object.
#' @param x A `kb_fit` object.
#' @param x_name A string naming `data` in error messages.
#' @param prior_only A flag specifying whether to sample from the priors only
#'   (the likelihood is switched off), for prior predictive checks.
#' @param chains A whole number of MCMC chains.
#' @param niters A whole number of saved post-warmup draws per chain, at least 2
#'   (warmup defaults to match).
#' @param nthin A whole number giving the thinning interval.
#' @param cores A whole number of cores for parallel chains, or `NULL` to use
#'   `getOption("mc.cores")` (falling back to `chains`), capped at the available
#'   cores.
#' @param seed A whole number passed to [rstan::sampling()] to make the fit
#'   reproducible, or `NULL` (the default). When `NULL`, a seed is drawn from
#'   R's RNG, so a preceding `set.seed()` also makes the fit reproducible.
#' @param progress A string, one of `"bar"` (the default, a console progress
#'   bar), `"verbose"` (rstan's per-iteration output and diagnostic warnings), or
#'   `"none"` (silent). Controls fit-time console output only.
#' @param progress_dir A string giving an existing directory in which to record
#'   progress for [kb_progress()], or `NULL` (the default) to record none.
#' @param conf_level A number greater than 0 and less than 1 giving the
#'   compatibility-interval level.
#' @param estimate A function that reduces a numeric vector of posterior draws to
#'   a scalar point estimate (e.g. `median` or `mean`).
#' @param sig_fig A whole number of significant figures for summary output.
#' @param include_random_effects A flag specifying whether to include the
#'   group-level random-effect terms in the output.
#' @param rhat A number giving the maximum acceptable Rhat.
#' @param ess A number giving the minimum acceptable bulk and tail effective
#'   sample size per chain.
#' @param max_perc_divergent A number giving the maximum acceptable percentage of
#'   saved draws that ended in a divergent transition.
#' @param by A character vector of grouping factors, `"site"`, `"year"`, or
#'   both, giving one row per fitted level (per observed site-year for both), or
#'   `NULL` for no grouping columns (the typical site and year).
#' @param new_levels A string, one of `"average"` (the default) or `"sample"`,
#'   giving how a site or year that is new or absent from `new_data` is
#'   treated (sites and years in the fit use their estimated effects):
#'   `"average"` uses the typical site or year; `"sample"` draws a new effect,
#'   so the interval includes the variation between sites or years. `"sample"`
#'   gives a different interval on each call; use `set.seed()` to reproduce it.
#' @param representative_site A character vector of sites in the fit whose
#'   effects a new site takes (averaged when several are named), or `NULL` (the
#'   default) to follow `new_levels`.
#' @keywords internal
#' @aliases parameters arguments args
#' @usage NULL
# nocov start
params <- function(...) NULL
# nocov end
