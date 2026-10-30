# Response scale of rvar `lp` at the rows of `grid`: the mean, or with
# `expectation = FALSE` the inverse link (they differ only where a method checks
# the flag). Bodies use arithmetic, not plogis(), which errors on an rvar.
.epred <- function(fit, lp, expectation = TRUE, grid = NULL) {
  UseMethod(".epred")
}

#' @export
.epred.default <- function(fit, lp, expectation = TRUE, grid = NULL) {
  .abort_no_method(fit, call = NULL)
}

#' @export
.epred.kb_fit_weight <- function(fit, lp, expectation = TRUE, grid = NULL) {
  exp(lp)
}

# Normal on log weight: exp(lp) is the median; the mean adds sd_residual^2 / 2.
#' @export
.epred.kb_fit_weight_nereo <- function(fit, lp, expectation = TRUE, grid = NULL) {
  if (!expectation) {
    return(exp(lp))
  }
  exp(lp + fit$draws$sd_residual^2 / 2)
}

#' @export
.epred.kb_fit_size <- function(fit, lp, expectation = TRUE, grid = NULL) {
  exp(lp)
}

#' @export
.epred.kb_fit_wetdry <- function(fit, lp, expectation = TRUE, grid = NULL) {
  1 / (1 + exp(-lp))
}

#' @export
.epred.kb_fit_carbon <- function(fit, lp, expectation = TRUE, grid = NULL) {
  1 / (1 + exp(-lp))
}

#' @export
.epred.kb_fit_nitrogen <- function(fit, lp, expectation = TRUE, grid = NULL) {
  1 / (1 + exp(-lp))
}

# The Gamma mean, times the probability that the plot holds plants where the
# fit has the presence part.
#' @export
.epred.kb_fit_cover_calibration <- function(fit, lp, expectation = TRUE, grid = NULL) {
  if (!expectation || !.presence_on(fit)) {
    return(exp(lp))
  }
  exp(lp) / (1 + exp(-presence_logit(fit, grid)))
}
