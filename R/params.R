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
#' @param iter A whole number of saved post-warmup iterations per chain.
#' @param nthin A whole number giving the thinning interval.
#' @param cores A whole number of cores, or `NULL` to fit chains in parallel.
#' @param quiet A flag specifying whether to suppress sampler output.
#' @param conf_level A number between 0 and 1 giving the compatibility-interval
#'   level.
#' @param estimate A function giving the point estimate (e.g. `median`).
#' @param sig_fig A whole number of significant figures for summary output.
#' @param by A character vector of grouping factors to predict by, or `NULL`
#'   for the population-level prediction.
#' @param uncertainty A string, one of `"marginal"` or `"typical"`, controlling
#'   how random-effect factors not named in `by` are treated.
#' @keywords internal
#' @aliases parameters arguments args
#' @usage NULL
# nocov start
# jarl-ignore unused_function: @inheritParams donor, intentionally never called
params <- function(...) NULL
# nocov end
