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
#' @param species A string naming the species. One of `"nereocystis"`.
#' @param priors A named list of prior objects (see [kb_priors_weight()]), or
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
#' @param quiet A flag specifying whether to suppress the sampler progress
#'   output. Diagnostic warnings (divergences, etc.) are suppressed regardless
#'   and surfaced through [converged()]/[glance()].
#' @param conf_level A number between 0 and 1 giving the compatibility-interval
#'   level.
#' @param estimate A function giving the point estimate (e.g. `median`).
#' @param sig_fig A whole number of significant figures for summary output.
#' @param include_random_effects A flag specifying whether to include the
#'   group-level random-effect terms in the output.
#' @param rhat A number giving the maximum acceptable Rhat.
#' @param esr A number giving the minimum acceptable effective sample rate
#'   (effective sample size divided by the number of draws).
#' @param by A character vector of grouping factors to draw a separate curve
#'   for, or `NULL` for a single population-level curve. Each named factor is
#'   expanded over its observed levels and conditioned on at its estimated
#'   random effects.
#' @param new_levels A string, one of `"sample"` or `"average"`, controlling how
#'   random effects that are not conditioned on are treated (factors absent from
#'   the prediction, and any new level not seen in the fit). `"sample"` draws a
#'   new random effect from `Normal(0, sd)`, widening the interval to include
#'   between-group variation; `"average"` holds the random effects at zero, giving
#'   the typical group. Known levels are always conditioned on.
#' @keywords internal
#' @aliases parameters arguments args
#' @usage NULL
# nocov start
# jarl-ignore unused_function: @inheritParams donor, intentionally never called
params <- function(...) NULL
# nocov end
