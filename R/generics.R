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

#' @importFrom universals esr
#' @export
universals::esr

#' @importFrom universals converged
#' @export
universals::converged

#' @importFrom universals estimates
#' @export
universals::estimates

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

#' @importFrom rstantools posterior_epred
#' @export
rstantools::posterior_epred

#' @importFrom rstantools posterior_linpred
#' @export
rstantools::posterior_linpred

#' @importFrom rstantools posterior_predict
#' @export
rstantools::posterior_predict

#' @importFrom rstantools log_lik
#' @export
rstantools::log_lik

#' @importFrom rstantools prior_summary
#' @export
rstantools::prior_summary

#' @importFrom ggplot2 autoplot
#' @export
ggplot2::autoplot

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
