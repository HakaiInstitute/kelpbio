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

# Log link for both species. Nereo's Student-t on log weight has no response-scale
# expectation, so exp(lp) is its median.
#' @export
.epred.kb_fit_weight <- function(fit, lp, expectation = TRUE) {
  exp(lp)
}
