# Computed from the estimated effects only (.fitted_draws()).

#' @exportS3Method universals::esr
esr.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  s <- .fitted_diagnostics(x)
  stats::setNames(s$ess_bulk / posterior::ndraws(x$draws), s$variable)
}

#' @exportS3Method universals::rhat
rhat.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  s <- .fitted_diagnostics(x)
  stats::setNames(s$rhat, s$variable)
}

#' @exportS3Method universals::estimates
estimates.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  m <- posterior::summarise_draws(.fitted_draws(x), estimate = stats::median)
  stats::setNames(m$estimate, m$variable)
}

#' @exportS3Method stats::nobs
nobs.kb_fit <- function(object, ...) {
  rlang::check_dots_empty()
  nrow(object$data)
}

#' @exportS3Method universals::nchains
nchains.kb_fit <- function(x, ...) {
  posterior::nchains(x$draws)
}

#' @exportS3Method universals::niters
niters.kb_fit <- function(x, ...) {
  posterior::niterations(x$draws)
}

#' @exportS3Method universals::npars
npars.kb_fit <- function(x, ...) {
  length(posterior::variables(.fitted_draws(x)))
}

#' @exportS3Method universals::nterms
nterms.kb_fit <- function(x, ...) {
  sum(lengths(.fitted_draws(x)))
}

#' @exportS3Method universals::pars
pars.kb_fit <- function(x, ...) {
  posterior::variables(.fitted_draws(x))
}
