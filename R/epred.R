# Response scale: `expectation = TRUE` the mean, `FALSE` the inverse link. These
# differ only for a mixture likelihood, so most methods ignore the flag. Write
# bodies with arithmetic: `1 / (1 + exp(-lp))`, since plogis() errors on an rvar.
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
