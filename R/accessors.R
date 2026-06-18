# Diagnostic and structural accessors for kb_fit, computed from the stored
# draws and diagnostics via posterior.

#' @rdname ess
#' @export
ess.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  s <- x$diagnostics$summary
  stats::setNames(s$ess_bulk, s$variable)
}

#' @exportS3Method universals::rhat
rhat.kb_fit <- function(x, ...) {
  rlang::check_dots_empty()
  s <- x$diagnostics$summary
  stats::setNames(s$rhat, s$variable)
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
  length(posterior::variables(x$draws))
}

#' @exportS3Method universals::nterms
nterms.kb_fit <- function(x, ...) {
  sum(vapply(x$draws, length, integer(1)))
}

#' @exportS3Method universals::pars
pars.kb_fit <- function(x, ...) {
  posterior::variables(x$draws)
}
