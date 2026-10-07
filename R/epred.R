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

# exp(lp) is the untruncated mean.
#' @export
.epred.kb_fit_size_macro <- function(fit, lp, expectation = TRUE) {
  if (!expectation) {
    return(exp(lp))
  }
  mean_gamma_pois_zt(exp(lp), fit$draws$dispersion)
}

# The offset is already in lp.
#' @export
.epred.kb_fit_density <- function(fit, lp, expectation = TRUE) {
  exp(lp)
}

# Zero-inflated: exp(lp) is the mean given a non-structural-zero transect.
#' @export
.epred.kb_fit_density_nereo <- function(fit, lp, expectation = TRUE) {
  if (!expectation) {
    return(exp(lp))
  }
  exp(lp) / (1 + exp(fit$draws$logit_zero_inflation))
}

#' @export
.epred.kb_fit_wetdry <- function(fit, lp, expectation = TRUE) {
  1 / (1 + exp(-lp))
}

#' @export
.epred.kb_fit_carbon <- function(fit, lp, expectation = TRUE) {
  1 / (1 + exp(-lp))
}

# No lognormal retransformation: the residual SD is error in the in situ
# estimates, not variation in biomass.
#' @export
.epred.kb_fit_cover_biomass <- function(fit, lp, expectation = TRUE) {
  exp(lp)
}
