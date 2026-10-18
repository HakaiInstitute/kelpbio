# D x length(u) quantiles of one site-year's Weibull size distribution, per
# draw, truncated above at `upper` and renormalised. `lp` has one value per draw.
plant_sizes <- function(fit, lp, upper, u) {
  shape <- as.vector(posterior::draws_of(fit$draws$shape))
  scale <- weibull_scale(exp(lp), shape)
  # shape and scale recycle down columns, so row d gets draw d's distribution.
  p <- outer(stats::pweibull(upper, shape, scale), u)
  matrix(stats::qweibull(p, shape, scale), nrow = length(lp))
}
