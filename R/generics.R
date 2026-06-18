#' @importFrom generics tidy
#' @export
generics::tidy

#' @importFrom generics glance
#' @export
generics::glance

#' @importFrom generics augment
#' @export
generics::augment

#' @importFrom universals rhat
#' @export
universals::rhat

#' @importFrom universals converged
#' @export
universals::converged

#' @importFrom universals npars
#' @export
universals::npars

#' @importFrom universals nterms
#' @export
universals::nterms

#' @importFrom universals nchains
#' @export
universals::nchains

#' @importFrom universals niters
#' @export
universals::niters

#' @importFrom universals pars
#' @export
universals::pars

#' Posterior Draws
#'
#' Extract the raw posterior draws from a fitted model object.
#'
#' @param x A fitted model object.
#' @param ... Unused.
#' @return A `posterior` draws object.
#' @export
samples <- function(x, ...) {
  UseMethod("samples")
}

#' Effective Sample Size
#'
#' Bulk effective sample size of a fitted model object's parameters.
#'
#' @param x A fitted model object.
#' @param ... Unused.
#' @return A named numeric vector or scalar.
#' @export
ess <- function(x, ...) {
  UseMethod("ess")
}
