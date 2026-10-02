# Beta deviance residual in the shape1/shape2 parameterisation of stats::dbeta().
# Named and parameterised as an extras function would be, so a later move to
# extras is a namespace swap. The wet/dry model is mean-parameterised:
# alpha = mu * precision, beta = (1 - mu) * precision.
#
# With the precision phi = alpha + beta fixed, the log-likelihood of one
# observation x is maximised where the score in the mean m is zero:
#   digamma(m * phi) - digamma((1 - m) * phi) = log(x) - log(1 - x).
# The left side increases in m, so the saturated mean is found by vectorised
# bisection on (0, 1). It is close to, but not exactly, x, so setting the
# saturated mean to x (as the analysis project's res_beta() does) can give a
# negative deviance.
#
# The deviance is zero for the observation whose saturated mean equals the
# fitted mean, x0 = plogis(digamma(alpha) - digamma(beta)), so the residual is
# signed by x - x0 rather than x - mu.
res_beta <- function(x, alpha, beta) {
  phi <- alpha + beta
  target <- log(x) - log1p(-x)
  lo <- rep_len(0, length(x))
  hi <- rep_len(1, length(x))
  phi <- rep_len(phi, length(x))
  for (i in seq_len(60L)) {
    m <- (lo + hi) / 2
    above <- digamma(m * phi) - digamma((1 - m) * phi) > target
    hi[above] <- m[above]
    lo[!above] <- m[!above]
  }
  m <- (lo + hi) / 2
  ll_sat <- stats::dbeta(x, m * phi, (1 - m) * phi, log = TRUE)
  ll_fit <- stats::dbeta(x, alpha, beta, log = TRUE)
  x0 <- stats::plogis(digamma(alpha) - digamma(beta))
  sign(x - x0) * sqrt(pmax(2 * (ll_sat - ll_fit), 0))
}
