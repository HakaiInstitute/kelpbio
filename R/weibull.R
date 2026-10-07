# Weibull helpers (shape/scale of stats::dweibull(), extras-style).

weibull_scale <- function(mu, shape) {
  mu / gamma(1 + 1 / shape)
}

log_lik_weibull <- function(x, shape, scale) {
  stats::dweibull(x, shape = shape, scale = scale, log = TRUE)
}

# With shape fixed the saturated scale is x, so the deviance is
# 2 * (t^shape - 1 - shape * log(t)) with t = x / scale. It is zero at
# x = scale, not at the mean (below the scale for shape > 1), so the sign is
# x - scale; signing by x - mean would flip observations between the two.
res_weibull <- function(x, shape, scale) {
  t <- x / scale
  dev <- 2 * (t^shape - 1 - shape * log(t))
  sign(x - scale) * sqrt(pmax(dev, 0))
}

ran_weibull <- function(n, shape, scale) {
  stats::rweibull(n, shape = shape, scale = scale)
}
