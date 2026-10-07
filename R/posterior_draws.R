# Methods for posterior's draws generics: a fit behaves as its draws.

#' @rdname kb_samples
#' @name kb_samples
#' @param x A `kb_fit` object.
#' @exportS3Method posterior::as_draws
as_draws.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(x)
  x$draws
}

#' @rdname kb_samples
#' @exportS3Method posterior::nchains
nchains.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  posterior::nchains(x$draws)
}

#' @rdname kb_samples
#' @exportS3Method posterior::niterations
niterations.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  posterior::niterations(x$draws)
}

#' @rdname kb_samples
#' @exportS3Method posterior::ndraws
ndraws.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  posterior::ndraws(x$draws)
}

#' @rdname kb_samples
#' @exportS3Method posterior::nvariables
nvariables.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  posterior::nvariables(x$draws)
}

#' @rdname kb_samples
#' @exportS3Method posterior::variables
variables.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  posterior::variables(x$draws)
}
