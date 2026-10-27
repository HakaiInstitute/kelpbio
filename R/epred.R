# Response scale of rvar `lp`: the mean, or with `expectation = FALSE` the
# inverse link (they differ only where a method checks the flag). Bodies use
# arithmetic, not plogis(), which errors on an rvar.
.epred <- function(fit, lp, expectation = TRUE) {
  UseMethod(".epred")
}

#' @export
.epred.default <- function(fit, lp, expectation = TRUE) {
  .abort_no_method(fit, call = NULL)
}

#' @export
.epred.kb_fit_weight <- function(fit, lp, expectation = TRUE) {
  exp(lp)
}

# Normal on log weight: exp(lp) is the median; the mean adds sd_residual^2 / 2.
#' @export
.epred.kb_fit_weight_nereo <- function(fit, lp, expectation = TRUE) {
  if (!expectation) {
    return(exp(lp))
  }
  exp(lp + fit$draws$sd_residual^2 / 2)
}

#' @export
.epred.kb_fit_size <- function(fit, lp, expectation = TRUE) {
  exp(lp)
}

#' @export
.epred.kb_fit_wetdry <- function(fit, lp, expectation = TRUE) {
  1 / (1 + exp(-lp))
}

#' @export
.epred.kb_fit_carbon <- function(fit, lp, expectation = TRUE) {
  1 / (1 + exp(-lp))
}

#' @export
.epred.kb_fit_nitrogen <- function(fit, lp, expectation = TRUE) {
  1 / (1 + exp(-lp))
}

# No lognormal retransformation: the residual SD is error in the in situ
# estimates, not variation in biomass.
#' @export
.epred.kb_fit_cover_calibration <- function(fit, lp, expectation = TRUE) {
  exp(lp)
}
