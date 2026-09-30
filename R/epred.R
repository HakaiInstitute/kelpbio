# Response scale: `expectation = TRUE` the mean, `FALSE` the inverse link. These
# differ only for a mixture likelihood, so most methods ignore the flag.
#
# `lp` arrives either as a posterior rvar (from fitted() and the prediction
# verbs) or as a D x N draws matrix (from the posterior_* generics), and a method
# must return the same type it was given. Write bodies with arithmetic:
# `1 / (1 + exp(-lp))`, not plogis(), since `/`, `+`, `-` and `exp` are Ops/Math
# group generics that work on both, while plogis() errors on an rvar.
.epred <- function(fit, lp, expectation = TRUE) {
  UseMethod(".epred")
}

#' @export
.epred.default <- function(fit, lp, expectation = TRUE) {
  .abort_no_method(x = fit, call = NULL)
}

# Log link for both species. For the Macrocystis Gamma, exp(lp) is the mean.
#' @export
.epred.kb_fit_weight <- function(fit, lp, expectation = TRUE) {
  exp(lp)
}

# Nereo is Normal on log weight, so exp(lp) is the median and the mean carries
# the lognormal retransformation exp(sWeight^2 / 2). A total such as biomass
# needs the mean.
#' @export
.epred.kb_fit_weight_nereo <- function(fit, lp, expectation = TRUE) {
  if (!expectation) {
    return(exp(lp))
  }
  sw <- fit$draws$sWeight
  if (!posterior::is_rvar(lp)) {
    # A D x N matrix: a length-D vector recycles down each column, so element
    # (d, n) gets draw d's residual SD.
    sw <- as.vector(posterior::draws_of(sw))
  }
  exp(lp + sw^2 / 2)
}
