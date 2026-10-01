# Weibull log-likelihood and deviance residual, in the shape/scale
# parameterisation of stats::dweibull(). Named and parameterised as extras
# functions would be, so a later move to extras is a namespace swap. The size
# model is mean-parameterised; weibull_scale() converts its mean to the scale.

weibull_scale <- function(mu, shape) {
  mu / gamma(1 + 1 / shape)
}

log_lik_weibull <- function(x, shape, scale) {
  stats::dweibull(x, shape = shape, scale = scale, log = TRUE)
}

# With the shape fixed, the log-likelihood of one observation is maximised at
# scale = x, so the saturated log-likelihood has the closed form
# log(shape) - log(x) - 1, and the deviance reduces to
# 2 * (t^shape - 1 - shape * log(t)) with t = x / scale.
#
# The residual is signed by x - scale, not x - mean: the deviance is zero at
# x = scale, and for shape > 1 the mean lies below the scale, so signing against
# the mean gives observations between the two the wrong sign and makes the
# residual discontinuous at the mean.
res_weibull <- function(x, shape, scale) {
  t <- x / scale
  dev <- 2 * (t^shape - 1 - shape * log(t))
  sign(x - scale) * sqrt(pmax(dev, 0))
}
