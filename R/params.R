#' Parameter Descriptions for Package
#'
#' Default parameter descriptions which may be overridden in individual
#' functions.
#'
#' A flag is a non-missing logical scalar.
#'
#' A string is a non-missing character scalar.
#
#' @inheritParams rlang::args_dots_empty
#' @param data A data frame of observations.
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
#'   reproducible, or `NULL` (the default). When `NULL`, rstan draws its own seed
#'   from R's RNG, so a preceding `set.seed()` also makes the fit reproducible; an
#'   explicit `seed` takes precedence over the RNG state.
#' @param quiet A flag specifying whether to suppress console output. When
#'   `FALSE` (the default), rstan's sampling progress and warnings are printed;
#'   when `TRUE`, all sampler output is suppressed.
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
#' @param by A character vector of grouping factors, each drawn as a separate
#'   curve, or `NULL` for a single population-level curve. Each named factor is
#'   expanded over its observed levels and conditioned on its estimated random
#'   effects.
#' @param new_levels A string, one of `"sample"` or `"average"`, controlling how
#'   random effects that are not conditioned on are treated (factors absent from
#'   the prediction, and any new level not seen in the fit). `"sample"` draws a
#'   new random effect from `Normal(0, sd)`, widening the interval to include
#'   between-group variation; `"average"` holds the random effects at zero,
#'   giving the typical group. Known levels are always conditioned on. `"sample"`
#'   draws fresh randomness on each call, so set a seed with `set.seed()` for a
#'   reproducible interval.
#' @param representative_site A character vector of site levels present in the
#'   fit, or `NULL` (the default). When supplied, a new or absent site takes its
#'   site main effects (intercept and slope) from the named reference site (the
#'   per-draw average when several are named), instead of the `new_levels`
#'   treatment; the `site:year` interaction still follows `new_levels`.
#' @keywords internal
#' @aliases parameters arguments args
#' @usage NULL
# nocov start
params <- function(...) NULL
# nocov end
