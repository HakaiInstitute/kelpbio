# Beta deviance residual (shape1/shape2 of stats::dbeta(), extras-style).
#
# With phi = alpha + beta fixed, the saturated mean m solves
#   digamma(m * phi) - digamma((1 - m) * phi) = log(x) - log(1 - x),
# whose left side increases in m, so it is found by bisection on (0, 1). m is
# not exactly x, so taking m = x (as the analysis project's res_beta() does) can
# give a negative deviance. The deviance is zero at
# x0 = plogis(digamma(alpha) - digamma(beta)), so the sign is x - x0, not x - mu.
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

ran_beta <- function(n, alpha, beta) {
  stats::rbeta(n, shape1 = alpha, shape2 = beta)
}
